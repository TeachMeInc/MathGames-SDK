package com.mathgames.api.local
{
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;

    final internal class RemoteSWF
    {
        static private const SDK_VERSION_CODE :String = "0";
        static private const BUST_CACHE :Boolean = true;

        private const _loaderListeners :Array = [
            [HTTPStatusEvent.HTTP_STATUS,       swfLoader_generalLog],
            [Event.INIT,                        swfLoader_generalLog],
            [Event.OPEN,                        swfLoader_generalLog],
            [ProgressEvent.PROGRESS,            swfLoader_generalLog],
            [Event.UNLOAD,                      swfLoader_generalLog],
            [IOErrorEvent.IO_ERROR,             swfLoader_ioError],
            [SecurityErrorEvent.SECURITY_ERROR, swfLoader_secError],
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

        private function swfLoader_ioError (e:IOErrorEvent) :void
        {
            swfLoader_removeListeners ();
            _swfLoadCallback (e.text);
        }

        private function swfLoader_secError (e:SecurityErrorEvent) :void
        {
            swfLoader_removeListeners ();
            _swfLoadCallback (e.text);
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

        private function checkLoadedAndLog () :Boolean
        {
            if (!loaded) {
                _log ("Attempting to invoke remote API calls, but SWF is not loaded");
            }
            return loaded;
        }

    // ---- Implementation of remote SWF function call proxies ----------------------------------------

        public function initialize (config:Object) :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("initialize", {
                "config": config
            });
        }

        public function showAuthPanel (callback:Function, cancelCallback:Function) :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("showAuthPanel", {
                "callback": callback,
                "cancelCallback": cancelCallback
            });
        }

        public function notifyStageResize (width:Number, height:Number, scaleX:Number, scaleY:Number) :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("notifyStageResize", {
                "width": width,
                "height": height,
                "scaleX": scaleX,
                "scaleY": scaleY
            });
        }

        public function showSupportedSkillStandards () :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("showSupportedSkillStandards");
        }

        public function startSession (config:Object, sessionReadyCallback:Function,
            questionReadyCallback:Function, averageTimeChangeCallback:Function) :void
        {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("startSession", {
                "config": config,
                "sessionReadyCallback": sessionReadyCallback,
                "questionReadyCallback": questionReadyCallback,
                "averageTimeChangeCallback": averageTimeChangeCallback
            });
        }

        public function endSession () :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("endSession");
        }

        public function postMetrics (key:String, data:Object) :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("postMetrics", {
                "key": key,
                "data": data
            });
        }

        public function setSoundEnabled (enabled:Boolean) :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("setSoundEnabled", {
                "enabled": enabled
            });
        }

        public function showProgress (callback:Function, readyCallback:Function, logoutCallback:Function) :void {
            if (! checkLoadedAndLog ()) return;
            _swfContent.invokeFunction ("showProgress", {
                "callback": callback,
                "readyCallback": readyCallback,
                "logoutCallback": logoutCallback
            });
        }
    }
}