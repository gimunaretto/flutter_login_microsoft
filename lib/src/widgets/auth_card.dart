import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/LoginUpload.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import '../constants.dart';
import 'animated_button.dart';
import 'custom_page_transformer.dart';
import 'expandable_container.dart';
import 'animated_text_form_field.dart';
import '../providers/auth.dart';
import '../providers/login_messages.dart';
import '../dart_helper.dart';
import '../matrix.dart';
import '../paddings.dart';
import '../widget_helper.dart';

class AuthCard extends StatefulWidget {
  AuthCard({
    Key key,
    this.padding = const EdgeInsets.all(0),
    this.loadingController,
    this.loginValidator,
    this.senhaValidator,
    this.onSubmit,
    this.onSubmitCompleted,
    this.onMicrosoftLogin,
  }) : super(key: key);

  final AnimationController loadingController;
  final FormFieldValidator<String> loginValidator;
  final Function onMicrosoftLogin;
  final Function onSubmit;
  final Function onSubmitCompleted;
  final EdgeInsets padding;
  final FormFieldValidator<String> senhaValidator;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  static const cardSizeScaleEnd = .2;

  GlobalKey _cardKey = GlobalKey();
  Animation<double> _cardOverlayHeightFactorAnimation;
  Animation<double> _cardOverlaySizeAndOpacityAnimation;
  Animation<double> _cardRotationAnimation;
  Animation<double> _cardSize2AnimationX;
  Animation<double> _cardSize2AnimationY;
  Animation<double> _cardSizeAnimation;
  Animation<double> _flipAnimation;
  AnimationController _formLoadingController;
  var _isLoadingFirstTime = true;
  TransformerPageController _pageController;
  var _pageIndex = 0;
  AnimationController _routeTransitionController;

  @override
  void dispose() {
    super.dispose();

    _formLoadingController.dispose();
    _pageController.dispose();
    _routeTransitionController.dispose();
  }

  @override
  void initState() {
    super.initState();

    _pageController = TransformerPageController();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd)
        .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(0, .27272727 /* ~300ms */, curve: Curves.easeInOutCirc),
    ));
    // replace 0 with minPositive to pass the test
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: double.minPositive, end: 1.0)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.27272727, .5 /* ~250ms */, curve: Curves.linear),
    ));
    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.5, .72727272 /* ~250ms */, curve: Curves.linear),
    ));
    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardRotationAnimation =
        Tween<double>(begin: 0, end: pi / 2).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1 /* ~300ms */, curve: Curves.easeInOutCubic),
    ));
  }

  void _switchRecovery(bool recovery) {
    final auth = Provider.of<Auth>(context, listen: false);

    auth.isRecover = recovery;
    if (recovery) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 1;
    } else {
      _pageController.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 0;
    }
  }

  Future<void> runLoadingAnimation() {
    if (widget.loadingController.isDismissed) {
      return widget.loadingController.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward();
        }
      });
    } else if (widget.loadingController.isCompleted) {
      return _formLoadingController
          .reverse()
          .then((_) => widget.loadingController.reverse());
    }
    return Future(null);
  }

  Future<void> _forwardChangeRouteAnimation() {
    final isLogin = Provider.of<Auth>(context, listen: false).isLogin;
    final deviceSize = MediaQuery.of(context).size;
    final cardSize = getWidgetSize(_cardKey);
    // add .25 to make sure the scaling will cover the whole screen
    final widthRatio =
        deviceSize.width / cardSize.height + (isLogin ? .25 : .65);
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX =
        Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));
    _cardSize2AnimationY =
        Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));

    widget?.onSubmit();

    return _formLoadingController
        .reverse()
        .then((_) => _routeTransitionController.forward());
  }

  void _reverseChangeRouteAnimation() {
    _routeTransitionController
        .reverse()
        .then((_) => _formLoadingController.forward());
  }

  void runChangeRouteAnimation() {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation();
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    _switchRecovery(!auth.isRecover);
  }

  Widget _buildLoadingAnimator({Widget child, ThemeData theme}) {
    Widget card;
    Widget overlay;

    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: Matrix.perspective()..rotateX(_flipAnimation.value),
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );

    // change-route transition
    overlay = Padding(
      padding: theme.cardTheme.margin,
      child: AnimatedBuilder(
        animation: _cardOverlayHeightFactorAnimation,
        builder: (context, child) => ClipPath.shape(
          shape: theme.cardTheme.shape,
          child: FractionallySizedBox(
            heightFactor: _cardOverlayHeightFactorAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.accentColor),
        ),
      ),
    );

    overlay = ScaleTransition(
      scale: _cardOverlaySizeAndOpacityAnimation,
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(child: overlay),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    Widget current = Container(
      height: deviceSize.height,
      width: deviceSize.width,
      padding: widget.padding,
      child: TransformerPageView(
        physics: NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 2,

        /// Need to keep track of page index because soft keyboard will
        /// make page view rebuilt
        index: _pageIndex,
        transformer: CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          final child = (index == 0)
              ? _buildLoadingAnimator(
                  theme: theme,
                  child: _LoginCard(
                    key: _cardKey,
                    loadingController: _isLoadingFirstTime
                        ? _formLoadingController
                        : (_formLoadingController..value = 1.0),
                    loginValidator: widget.loginValidator,
                    senhaValidator: widget.senhaValidator,
                    onSwitchRecoveryPassword: () => _switchRecovery(true),
                    onSubmitCompleted: () {
                      _forwardChangeRouteAnimation().then((_) {
                        widget?.onSubmitCompleted();
                      });
                    },
                    onMicrosoftLogin: () {
                      widget?.onMicrosoftLogin();
                    },
                  ),
                )
              : _RecoverCard(
                  loginValidator: widget.loginValidator,
                  onSwitchLogin: () => _switchRecovery(false),
                );

          return Align(
            alignment: Alignment.topCenter,
            child: child,
          );
        },
      ),
    );

    return AnimatedBuilder(
      animation: _cardSize2AnimationX,
      builder: (context, snapshot) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_cardRotationAnimation.value)
            ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)
            ..scale(_cardSize2AnimationX.value, _cardSize2AnimationY.value),
          child: current,
        );
      },
    );
  }
}

class _LoginCard extends StatefulWidget {
  _LoginCard({
    Key key,
    this.loadingController,
    @required this.loginValidator,
    @required this.senhaValidator,
    @required this.onSwitchRecoveryPassword,
    this.onSwitchAuth,
    this.onSubmitCompleted,
    this.onMicrosoftLogin,
  }) : super(key: key);

  final AnimationController loadingController;
  final FormFieldValidator<String> loginValidator;
  final Function onMicrosoftLogin;
  final Function onSubmitCompleted;
  final Function onSwitchAuth;
  final Function onSwitchRecoveryPassword;
  final FormFieldValidator<String> senhaValidator;

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> with TickerProviderStateMixin {
  Animation<double> _buttonScaleAnimation;
  TextEditingController _confirmPassController;
  final _confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  var _isSubmitting = false;

  /// switch between login and signup
  AnimationController _loadingController;

  TextEditingController _nameController;
  Interval _nameTextFieldLoadingAnimationInterval;
  TextEditingController _passController;
  Interval _passTextFieldLoadingAnimationInterval;
  AnimationController _postSwitchAuthController;
  final _senhaFocusNode = FocusNode();
  var _showShadow = true;
  AnimationController _submitController;
  AnimationController _switchAuthController;
  // Interval _textButtonLoadingAnimationInterval;

  @override
  void dispose() {
    super.dispose();

    _loadingController?.removeStatusListener(handleLoadingAnimationStatus);
    _senhaFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();
    _submitController.dispose();
  }

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = TextEditingController(text: auth.login);
    _passController = TextEditingController(text: auth.senha);
    _confirmPassController = TextEditingController(text: auth.confirmPassword);

    _loadingController = widget.loadingController ??
        (AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 1150),
          reverseDuration: Duration(milliseconds: 300),
        )..value = 1.0);

    _loadingController?.addStatusListener(handleLoadingAnimationStatus);

    _switchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
    _passTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
    // _textButtonLoadingAnimationInterval =
    //     const Interval(.6, 1.0, curve: Curves.easeOut);
    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));
  }

  bool get buttonEnabled => !_isLoading && !_isSubmitting;

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  // void _switchAuthMode() {
  //   final auth = Provider.of<Auth>(context, listen: false);
  //   final newAuthMode = auth.switchAuth();

  //   if (newAuthMode == AuthMode.Signup) {
  //     _switchAuthController.forward();
  //   } else {
  //     _switchAuthController.reverse();
  //   }
  // }

  Future<bool> _submit() async {
    // a hack to force unfocus the soft keyboard. If not, after change-route
    // animation completes, it will trigger rebuilding this widget and show all
    // textfields and buttons again before going to new route
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return false;
    }

    _formKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<Auth>(context, listen: false);
    String error;

    if (auth.isLogin) {
      error = await auth.onLogin(LoginUpload(
        login: auth.login,
        senha: auth.senha,
      ));
    } else {
      error = await auth.onSignup(LoginUpload(
        login: auth.login,
        senha: auth.senha,
      ));
    }

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      setState(() => _showShadow = false);
    });

    _submitController.reverse();

    if (!DartHelper.isNullOrEmpty(error)) {
      showErrorToast(context, error);
      Future.delayed(const Duration(milliseconds: 271), () {
        setState(() => _showShadow = true);
      });
      setState(() => _isSubmitting = false);
      return false;
    }

    widget?.onSubmitCompleted();

    return true;
  }

  Widget _buildNameField(double width, LoginMessages messages, Auth auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: messages.usernameHint,
      prefixIcon: Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_senhaFocusNode);
      },
      validator: widget.loginValidator,
      onSaved: (value) => auth.login = value,
    );
  }

  Widget _buildPasswordField(double width, LoginMessages messages, Auth auth) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      loadingController: _loadingController,
      interval: _passTextFieldLoadingAnimationInterval,
      labelText: messages.senhaHint,
      controller: _passController,
      textInputAction:
          auth.isLogin ? TextInputAction.done : TextInputAction.next,
      focusNode: _senhaFocusNode,
      onFieldSubmitted: (value) {
        if (auth.isLogin) {
          _submit();
        } else {
          // SignUp
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        }
      },
      validator: widget.senhaValidator,
      onSaved: (value) => auth.senha = value,
    );
  }

  Widget _buildConfirmPasswordField(
      double width, LoginMessages messages, Auth auth) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      enabled: auth.isSignup,
      loadingController: _loadingController,
      inertiaController: _postSwitchAuthController,
      inertiaDirection: TextFieldInertiaDirection.right,
      labelText: messages.confirmPasswordHint,
      controller: _confirmPassController,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onFieldSubmitted: (value) => _submit(),
      validator: auth.isSignup
          ? (value) {
              if (value != _passController.text) {
                return messages.confirmPasswordError;
              }
              return null;
            }
          : (value) => null,
      onSaved: (value) => auth.confirmPassword = value,
    );
  }

  // Widget _buildForgotPassword(ThemeData theme, LoginMessages messages) {
  //   return FadeIn(
  //     controller: _loadingController,
  //     fadeDirection: FadeDirection.bottomToTop,
  //     offset: .5,
  //     curve: _textButtonLoadingAnimationInterval,
  //     child: FlatButton(
  //       child: AutoSizeText(
  //         messages.forgotPasswordButton,
  //         style: theme.textTheme.bodyText2,
  //         textAlign: TextAlign.left,
  //       ),
  //       onPressed: buttonEnabled ? () {
  //         // save state to populate login field on recovery card
  //         _formKey.currentState.save();
  //         widget.onSwitchRecoveryPassword();
  //       } : null,
  //     ),
  //   );
  // }

  Widget _buildSubmitButton(
      ThemeData theme, LoginMessages messages, Auth auth, double width) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        width: width,
        controller: _submitController,
        text: auth.isLogin ? messages.loginButton : messages.signupButton,
        onPressed: _submit,
      ),
    );
  }

  Widget optionText(double width) {
    return ScaleTransition(
        scale: _buttonScaleAnimation,
        child: Container(
          height: 40,
          width: width,
          alignment: Alignment.center,
          child: Row(children: <Widget>[
            Expanded(
                child: Divider(
              thickness: 1,
            )),
            Text(
              " ou faça login com microsoft ".toUpperCase(),
              style: TextStyle(fontSize: 10),
            ),
            Expanded(
                child: Divider(
              thickness: 1,
            )),
          ]),
        ));
  }

  Widget microsoftButton(ThemeData theme, double width) {
    return ScaleTransition(
        scale: _buttonScaleAnimation,
        child: Container(
          height: 40,
          width: width,
          // alignment: Alignment.center,
          child: RaisedButton.icon(
            color: theme.primaryColor,
            textColor: Colors.white,
            icon: Image.asset(
              'assets/images/microsoft.png',
              width: 15,
              height: 15,
            ),
            label: Text('MICROSOFT'),
            onPressed: () {
              widget.onMicrosoftLogin();
            },
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(100.0),
                side: BorderSide(color: Theme.of(context).primaryColor)),
          ),
        ));
  }

  // Widget _buildSwitchAuthButton(ThemeData theme, LoginMessages messages, Auth auth) {
  //   return FadeIn(
  //     controller: _loadingController,
  //     offset: .5,
  //     curve: _textButtonLoadingAnimationInterval,
  //     fadeDirection: FadeDirection.topToBottom,
  //     child: FlatButton(
  //       child: AnimatedAutoSizeText(
  //         text: auth.isSignup ? messages.loginButton : messages.signupButton,
  //         textRotation: AnimatedTextRotation.down,
  //       ),
  //       disabledTextColor: theme.primaryColor,
  //       onPressed: buttonEnabled ? _switchAuthMode : null,
  //       padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
  //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //       textColor: theme.primaryColor,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isLogin = auth.isLogin;
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final authForm = Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: cardPadding,
              right: cardPadding,
              top: cardPadding + 10,
            ),
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildNameField(textFieldWidth, messages, auth),
                SizedBox(height: 10),
                _buildPasswordField(textFieldWidth, messages, auth),
              ],
            ),
          ),
          ExpandableContainer(
            backgroundColor: theme.accentColor,
            controller: _switchAuthController,
            initialState: isLogin
                ? ExpandableContainerState.shrunk
                : ExpandableContainerState.expanded,
            alignment: Alignment.topLeft,
            color: theme.cardTheme.color,
            width: cardWidth,
            padding: EdgeInsets.symmetric(
              horizontal: cardPadding,
              vertical: 10,
            ),
            onExpandCompleted: () => _postSwitchAuthController.forward(),
            child: _buildConfirmPasswordField(textFieldWidth, messages, auth),
          ),
          Container(
            padding: Paddings.fromRBL(cardPadding),
            width: cardWidth,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                _buildSubmitButton(theme, messages, auth, textFieldWidth),
                optionText(textFieldWidth),
                microsoftButton(theme, textFieldWidth),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );

    return FittedBox(
      child: Card(
        elevation: _showShadow ? theme.cardTheme.elevation : 0,
        child: authForm,
      ),
    );
  }
}

class _RecoverCard extends StatefulWidget {
  _RecoverCard({
    Key key,
    @required this.loginValidator,
    @required this.onSwitchLogin,
  }) : super(key: key);

  final FormFieldValidator<String> loginValidator;
  final Function onSwitchLogin;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();
  var _isSubmitting = false;
  TextEditingController _nameController;
  AnimationController _submitController;

  @override
  void dispose() {
    super.dispose();
    _submitController.dispose();
  }

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = new TextEditingController(text: auth.login);

    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  Future<bool> _submit() async {
    if (!_formRecoverKey.currentState.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onRecoverPassword(auth.login);

    if (error != null) {
      showErrorToast(context, error);
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      return false;
    } else {
      showSuccessToast(context, messages.recoverPasswordSuccess);
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      return true;
    }
  }

  Widget _buildRecoverNameField(
      double width, LoginMessages messages, Auth auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      width: width,
      labelText: messages.usernameHint,
      prefixIcon: Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.loginValidator,
      onSaved: (value) => auth.login = value,
    );
  }

  Widget _buildRecoverButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.recoverPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(ThemeData theme, LoginMessages messages) {
    return FlatButton(
      child: AutoSizeText(messages.goBackButton),
      onPressed: !_isSubmitting
          ? () {
              _formRecoverKey.currentState.save();
              widget.onSwitchLogin();
            }
          : null,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return FittedBox(
      // width: cardWidth,
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: [
                AutoSizeText(
                  messages.recoverPasswordIntro,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                SizedBox(height: 20),
                _buildRecoverNameField(textFieldWidth, messages, auth),
                SizedBox(height: 20),
                AutoSizeText(
                  messages.recoverPasswordDescription,
                  key: kRecoverPasswordDescriptionKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                SizedBox(height: 26),
                _buildRecoverButton(theme, messages),
                _buildBackButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
