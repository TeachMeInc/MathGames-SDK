package com.mathgames.api.local
{
    import flash.display.*;
    import flash.events.*;

    final public class MathGames extends EventDispatcher implements IMathGames
    {
        static private const PRODUCTION_API_SWF_URL :String = "https://api.mathgames.com/api-remote.swf";

    // ----- Persistent state ---------------------------------------------------------------------

        private var _logFunc   :Function;
        private var _stage     :Stage;
        private var _container :DisplayObjectContainer;
        private var _remote    :RemoteSWF;

    // ----- Singleton instantiation stuff --------------------------------------------------------

        static private var s_this :MathGames = null;
        static private var s_allowInstantiation :Boolean = false;

        static public function get instance () :MathGames {
            if (s_this == null) {
                s_allowInstantiation = true;
                s_this = new MathGames;
                s_allowInstantiation = false;
            }
            return s_this;
        }

        public function MathGames ()
        {
            if (!s_allowInstantiation)
                throw new Error ("Cannot directly instantiate singleton class 'MathGames'.");

            _remote = new RemoteSWF ();
        }

    // ----- Logging ------------------------------------------------------------------------------

        private function log (msg:String) :void {
            if (_logFunc != null) _logFunc (msg);
        }

    // ----- Error / success callbacks ------------------------------------------------------------

        private function dispatchError (err:String) :void {
            dispatchEvent (new MathGamesEvent (MathGamesEvent.ERROR, err));
        }

        private function dispatchErrorOr (action:Function) :Function {
            return function (err:String) :void {
                if (err !== null) dispatchError (err);
                else action ();
            }
        }

        private function dispatchErrorOrSuccess (successEvent:String) :Function {
            return dispatchErrorOr (function () :void {
                dispatchEvent (new MathGamesEvent (successEvent));
            });
        }

    // ----- Initialization and auth panel management ---------------------------------------------

        public function connect (container:DisplayObjectContainer, config:Object) :void
        {
            _container = container;

            if (_container.stage === null) {
                dispatchError ("Provided container must be attached to the stage.");
                return;
            }

            _stage = _container.stage;

            _logFunc = config["log_func"] is Function
                     ? config["log_func"]
                     : null;

            var flashVars :Object = _stage.root.loaderInfo.parameters;
            config["hosted"] = !!flashVars["hosted"] && flashVars["hosted"] === "true";
            config["hosted_env"] = flashVars["hosted_env"];
            config["entity"] = flashVars["entity"];

            var staging :Boolean = config["hosted"] && config["hosted_env"] === "staging" && config["staging_swf"];
            var swfUrl :String = staging ? config["staging_swf"] : PRODUCTION_API_SWF_URL;

            _remote.loadSWF (swfUrl, _logFunc, dispatchErrorOr (function():void {
                _remote.contents.x = 0;
                _remote.contents.y = 0;
                _container.addChild (_remote.contents);

                _remote.initialize (config);

                _remote.notifyStageResize (_stage.stageWidth, _stage.stageHeight);
                _stage.addEventListener (Event.RESIZE, function (e:Event) :void {
                    _remote.notifyStageResize (_stage.stageWidth, _stage.stageHeight);
                });

                dispatchEvent (new MathGamesEvent (MathGamesEvent.CONNECTED));
            }));
        }

        public function authenticate () :void
        {
            _remote.showAuthPanel (dispatchErrorOrSuccess (MathGamesEvent.AUTHENTICATED), authCancel);
        }

        private function authCancel () :void
        {
            dispatchEvent (new MathGamesEvent (MathGamesEvent.AUTH_CANCELLED));
        }

    // ----- Gameplay session management ----------------------------------------------------------

        public function startSession (config:Object) :void
        {
            // If we're passing in the question panel objects, then added parent references here
            //  to avoid security sandbox violations which occur when trying to access "parent" remotely.
            if (config["question_panel"] !== undefined) {
                config["question_panel"]["question_area_parent"] = config["question_panel"]["question_area"].parent;
                for each (var btn:Object in config["question_panel"]["answer_buttons"]) {
                    btn["bounds_parent"] = btn["bounds"].parent;
                }
            }

            _remote.startSession (config, dispatchErrorOrSuccess (MathGamesEvent.SESSION_READY));
        }

        public function endSession () :void
        {
            _remote.endSession ();
        }

        public function postMetrics (key:String, data:Object) :void
        {
            _remote.postMetrics (key, data);
        }

        public function showProgress () :void
        {
            var successOrErrorCallback :Function =
                dispatchErrorOrSuccess (MathGamesEvent.PROGRESS_CLOSED);

            _remote.showProgress (successOrErrorCallback, progressReadyCallback, logoutCallback);
        }

        private function progressReadyCallback () :void
        {
            dispatchEvent (new MathGamesEvent (MathGamesEvent.PROGRESS_OPENED));
        }

        private function logoutCallback () :void
        {
            dispatchEvent (new MathGamesEvent (MathGamesEvent.LOGOUT));
        }

    // ----- Misc ---------------------------------------------------------------------------------

        public function setSoundEnabled (enabled:Boolean) :void
        {
            _remote.setSoundEnabled (enabled);
        }

        public function showSupportedSkillStandards () :void
        {
            _remote.showSupportedSkillStandards ();
        }

    // --------------------------------------------------------------------------------------------
    }
}

// ================================================================================================

import flash.display.*;
import flash.events.*;
import flash.net.*;
import flash.utils.*;

class RemoteSWF
{
    static private const SDK_VERSION_CODE :String = "0";
    static private const BUST_CACHE :Boolean = true;

    private const _loaderListeners :Array = [
        [HTTPStatusEvent.HTTP_STATUS,       swfLoader_generalLog],
        [Event.INIT,                        swfLoader_generalLog],
        [Event.OPEN,                        swfLoader_generalLog],
        [ProgressEvent.PROGRESS,            swfLoader_generalLog],
        [Event.UNLOAD,                      swfLoader_generalLog],
        [IOErrorEvent.IO_ERROR,             swfLoader_generalError],
        [SecurityErrorEvent.SECURITY_ERROR, swfLoader_generalError],
        [Event.COMPLETE,                    swfLoader_success]
    ];

    private var _swfLoader :Loader;
    private var _swfLoadCallback :Function;
    private var _swfContent :MovieClip;

    private var _log :Function;

    public function get loaded () :Boolean { return _swfContent != null }
    public function get contents () :DisplayObject { return _swfLoader || _swfContent }

    /**
     * Loads the remote MathGames resources SWF.
     *
     * @param callback  function (error:String) :void
     */
    public function loadSWF (swfUrl:String, log:Function, callback:Function) :void
    {
        _log = log;
        _swfLoadCallback = callback;

        var linkedApi :Class;

        try {
            linkedApi = getDefinitionByName("com.mathgames.api.remote.SWFMain") as Class;
        } catch (e:Error) {
            linkedApi = null;
        }

        if (linkedApi) {
            _swfLoader = null;
            _swfContent = new linkedApi;
            _log ("!!! Using statically linked API SWF !!!");
            _swfLoadCallback (null);
        } else {
            _swfLoader = new Loader;
            swfLoader_addListeners ();
            if (BUST_CACHE) swfUrl += "?_=" + Math.random().toString().substr(2);
            _swfLoader.load (new URLRequest (swfUrl));
        }
    }

    private function swfLoader_addListeners () :void
    {
        for (var i:int = 0; i < _loaderListeners.length; ++i) {
            _swfLoader.contentLoaderInfo.addEventListener (_loaderListeners[i][0], _loaderListeners[i][1]);
        }
    }

    private function swfLoader_removeListeners () :void
    {
        for (var i:int = 0; i < _loaderListeners.length; ++i) {
            _swfLoader.contentLoaderInfo.removeEventListener (_loaderListeners[i][0], _loaderListeners[i][1]);
        }
    }

    private function swfLoader_generalLog (e:Event) :void
    {
        _log ("Connection event: " + e.type);
    }

    private function swfLoader_generalError (e:Event) :void
    {
        swfLoader_removeListeners ();
        _swfLoadCallback (e.type);
    }

    private function swfLoader_success (e:Event) :void
    {
        swfLoader_removeListeners ();

        var err:String = null;
        try {
            _swfContent = _swfLoader.content as MovieClip;
            _swfContent.notifyVersion (SDK_VERSION_CODE);
        } catch (e:Error) {
            err = e.toString ();
        }
        _swfLoadCallback (err);
    }

    private function ifNotLoadedThrowError () :void
    {
        if (!loaded) {
            throw new Error ("Attempting to invoke remote API calls, but SWF is not loaded");
        }
    }

// ---- Implementation of remote SWF function call proxies ----------------------------------------

    public function initialize (config:Object) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("initialize", {
            "config": config
        });
    }

    public function showAuthPanel (callback:Function, cancelCallback:Function) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("showAuthPanel", {
            "callback": callback,
            "cancelCallback": cancelCallback
        });
    }

    public function notifyStageResize (width:Number, height:Number) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("notifyStageResize", {
            "width": width,
            "height": height
        });
    }

    public function showSupportedSkillStandards () :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("showSupportedSkillStandards");
    }

    public function startSession (config:Object, callback:Function) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("startSession", {
            "config": config,
            "callback": callback
        });
    }

    public function endSession () :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("endSession");
    }

    public function postMetrics (key:String, data:Object) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("postMetrics", {
            "key": key,
            "data": data
        });
    }

    public function setSoundEnabled (enabled:Boolean) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("setSoundEnabled", {
            "enabled": enabled
        });
    }

    public function showProgress (callback:Function, readyCallback:Function, logoutCallback:Function) :void {
        ifNotLoadedThrowError ();
        _swfContent.invokeFunction ("showProgress", {
            "callback": callback,
            "readyCallback": readyCallback,
            "logoutCallback": logoutCallback
        });
    }
}
