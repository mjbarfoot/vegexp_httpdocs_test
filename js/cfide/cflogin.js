function  _CF_checkfrmLogin(_CF_this)
    {
        //reset on submit
        _CF_error_exists = false;
        _CF_error_messages = new Array();
        _CF_error_fields = new Object();
        _CF_FirstErrorField = null;

        //form element userLogin required check
        if( _CF_hasValue(_CF_this['userLogin'], "TEXT", false ) )
        {
            //form element userLogin 'REGEX' validation checks
            if (!_CF_checkregex(_CF_this['userLogin'].value, /^[A-z/\-0-9]{2,12}/, true))
            {
                _CF_onError(_CF_this, "userLogin", _CF_this['userLogin'].value, "Please enter your Account ID.");
                _CF_error_exists = true;
            }

        }else {
            _CF_onError(_CF_this, "userLogin", _CF_this['userLogin'].value, "Please enter your Account ID.");
            _CF_error_exists = true;
        }

        //form element userPass required check
        if( _CF_hasValue(_CF_this['userPass'], "PASSWORD", false ) )
        {
            //form element userPass 'REGEX' validation checks
            if (!_CF_checkregex(_CF_this['userPass'].value, /^[A-z\-0-9]{6,12}/, true))
            {
                _CF_onError(_CF_this, "userPass", _CF_this['userPass'].value, "Please enter a password");
                _CF_error_exists = true;
            }

        }else {
            _CF_onError(_CF_this, "userPass", _CF_this['userPass'].value, "Please enter a password");
            _CF_error_exists = true;
        }


        //display error messages and return success
        if( _CF_error_exists )
        {
            if( _CF_error_messages.length > 0 )
            {
                // show alert() message
                _CF_onErrorAlert(_CF_error_messages);
                // set focus to first form error, if the field supports js focus().
                if( _CF_this[_CF_FirstErrorField].type == "text" )
                { _CF_this[_CF_FirstErrorField].focus(); }

            }
            return false;
        }else {
            return true;
        }
    }