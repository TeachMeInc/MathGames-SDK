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

            var hostedOnStaging :Boolean = config["hosted"] && config["hosted_env"] === "staging";
            var staging :Boolean = (config["force_staging"] || hostedOnStaging) && config["staging_swf"];
            var swfUrl :String = staging ? config["staging_swf"] : PRODUCTION_API_SWF_URL;

            _remote.loadSWF (swfUrl, _logFunc, function(err:String):void {
                if (err) {
                    var errBox:ErrorDialog = new ErrorDialog;
                    _container.addChild (errBox);
                    errBox.addEventListener (Event.CLOSE, function(e:Event):void {
                        _container.removeChild (errBox);
                        connect (container, config);
                    },false,0,true);
                    return;
                }

                _remote.contents.x = 0;
                _remote.contents.y = 0;
                _container.addChild (_remote.contents);

                _remote.initialize (config);

                _remote.notifyStageResize (_stage.stageWidth, _stage.stageHeight, _container.scaleX, _container.scaleY);
                _stage.addEventListener (Event.RESIZE, function (e:Event) :void {
                    _remote.notifyStageResize (_stage.stageWidth, _stage.stageHeight, _container.scaleX, _container.scaleY);
                });

                dispatchEvent (new MathGamesEvent (MathGamesEvent.CONNECTED));
            });
        }

        public function selectSkill () :void
        {
            _remote.selectSkill (
                function():void {
                    dispatchEvent (new MathGamesEvent (MathGamesEvent.SKILL_SELECTED));
                }, function() :void {
                    dispatchEvent (new MathGamesEvent (MathGamesEvent.SKILL_SELECT_CANCELLED));
                },
                dispatchError
            );
        }

    // ----- Gameplay session management ----------------------------------------------------------

        public function startSession (config:Object) :void
        {
            _remote.startSession (config,
                dispatchErrorOrSuccess (MathGamesEvent.SESSION_READY),
                questionReadyCallback,
                averageTimeChangeCallback);
        }

        public function endSession () :void
        {
            _remote.endSession ();
        }

        public function showSupportedSkillStandards () :void
        {
            _remote.showSupportedSkillStandards ();
        }

        public function showProgress () :void
        {
            _remote.showProgress (function():void {
                dispatchEvent (new MathGamesEvent (MathGamesEvent.PROGRESS_CLOSED));
            });
        }

        private function questionReadyCallback (params:Object) :void
        {
            var question :Question = new Question;
            question.question = params["question"];
            question.answers = Vector.<BitmapData>(params["answers"]);
            question.correctIndex = params["correctIndex"];
            question.doAnswer = params["doAnswer"];

            dispatchEvent (new MathGamesEvent (MathGamesEvent.QUESTION_READY, question));
        }

        private function averageTimeChangeCallback (time:int) :void
        {
            dispatchEvent (new MathGamesEvent (MathGamesEvent.AVERAGE_TIME_CHANGE, time));
        }


        public function postMetrics (key:String, data:Object) :void
        {
            _remote.postMetrics (key, data);
        }

        public function setSoundEnabled (enabled:Boolean) :void
        {
            _remote.setSoundEnabled (enabled);
        }

    // --------------------------------------------------------------------------------------------
    }
}