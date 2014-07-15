package
{
    import com.mathgames.api.local.*;
    import com.mathgames.api.local.qpanel.*;
    import flash.display.*;
    import flash.events.*;

    public class SampleGameMain extends MovieClip
    {
        private var _mathgames :IMathGames;
        private var _game :GameController;
        private var _questionPanel :QuestionPanel;

        public function SampleGameMain ()
        {
            _mathgames = MathGames.instance;

            this.customQuestions.visible = false;

            if (stage) init ();
            else addEventListener (Event.ADDED_TO_STAGE, init);
        }

        private function init (e:Event = null) :void
        {
            if (e) removeEventListener (Event.ADDED_TO_STAGE, init);

            var apiHolder = new Sprite;
            apiHolder.x = stage.stageWidth / 2;
            apiHolder.y = stage.stageHeight / 2;
            addChild (apiHolder);

            log (">> Loading MathGames remote resources SWF...");

            _mathgames.addEventListener (MathGamesEvent.CONNECTED, mathgames_connected);
            _mathgames.addEventListener (MathGamesEvent.LOGOUT, mathgames_logout);
            _mathgames.addEventListener (MathGamesEvent.ERROR, mathgames_error);
            _mathgames.addEventListener (MathGamesEvent.AUTH_CANCELLED, mathgames_authCancel);
            _mathgames.addEventListener (MathGamesEvent.AUTHENTICATED, mathgames_authComplete);
            _mathgames.addEventListener (MathGamesEvent.SESSION_READY, mathgames_sessionReady);
            _mathgames.addEventListener (MathGamesEvent.PROGRESS_OPENED, mathgames_progressOpened);
            _mathgames.addEventListener (MathGamesEvent.PROGRESS_CLOSED, mathgames_progressClosed);

            _game = new GameController (this.ball);

            _mathgames.connect (apiHolder, {
                "api_key": "528e1abeb4967cb32b00028e",
                "pool_key": "COMPLETE",
                "log_func": log
            });
            _questionPanel = new QuestionPanel (_mathgames);

			_questionPanel.addEventListener (QuestionPanel.EVENT_ANSWER_CORRECT, question_answerCorrect);
            _questionPanel.addEventListener (QuestionPanel.EVENT_ANSWER_INCORRECT, question_answerIncorrect);
        }

        private function mathgames_error (e:MathGamesEvent) :void
        {
            log (">> Error occurred:");
            log (e.data as String);
        }

        private function mathgames_logout (e:MathGamesEvent) :void
        {
            log (">> Logged out.");
        }

        private function mathgames_connected (e:MathGamesEvent) :void
        {
            log (">> mathgames_connected");
            _mathgames.authenticate ();
        }

        private function mathgames_authCancel (e:MathGamesEvent) :void
        {
            log (">> Auth cancelled.");
        }

        private function mathgames_authComplete (e:MathGamesEvent) :void
        {
            log (">> mathgames_authComplete");
            newSession ();
        }

        private function newSession () :void
        {
            this.customQuestions.visible = true;

            var qpConfig :Object = {
                "question_area": this.customQuestions.questionArea,
                "answer_buttons": []
            };

            var answerBtns :Vector.<MovieClip> = new <MovieClip> [
                this.customQuestions.answer0,
                this.customQuestions.answer1,
                this.customQuestions.answer2,
                this.customQuestions.answer3
            ];

            for each (var answerBtn:MovieClip in answerBtns) {
                answerBtn.buttonMode = true;
                answerBtn.mouseChildren = false;

                qpConfig["answer_buttons"].push ({
                    "bounds": answerBtn.answerArea,
                    "click_target": answerBtn,
                    "visibility_target": answerBtn
                })
            }

            _mathgames.startSession ({});
            _questionPanel.configure (qpConfig);
        }

        private function mathgames_sessionReady (e:MathGamesEvent):void
        {
            _game.start ();
        }

        private function question_answerCorrect   (e:Event) :void { answer (true); }
        private function question_answerIncorrect (e:Event) :void { answer (false); }

        private function answer (correct:Boolean) :void
        {
            if (!_game.answerQuestion (correct)) {
                _game.stop ();
                _mathgames.showProgress ();
            }
        }

        private function mathgames_progressOpened (e:MathGamesEvent) :void
        {
            log (">> Progress panel opened.");
        }

        private function mathgames_progressClosed (e:MathGamesEvent) :void
        {
            log (">> Progress panel closed. Starting new play session");
            newSession ();
        }
    }
}

import flash.display.*;
import flash.events.*;
import flash.external.*;

function log (msg:String) :void {
    trace (msg);
    if (ExternalInterface.available) {
        ExternalInterface.call ("console.log", msg);
    }
}

class GameController
{
    private var _mc :MovieClip;
    private var _targetX :Number;

    public function GameController (ballClip:MovieClip) {
        _mc = ballClip;
        _mc.visible = false;
        _targetX = 320;
        _mc.addEventListener (Event.ENTER_FRAME, enterFrame, false, 0, true);
    }

    private function enterFrame (e:Event) :void {
        _mc.x += (_targetX - _mc.x) / 20;
    }

    public function start () :void {
        _mc.visible = true;
    }

    public function stop () :void {
        _mc.visible = false;
        _targetX = 320;
    }

    public function answerQuestion (correct:Boolean) :Boolean {
        _targetX += correct ? 10 : -10 ;
        return _targetX > 95 && _targetX < 565;
    }
}


// The following block is used internally by TeachMe Inc for debugging.
// You can safely ignore it.
CONFIG::DEV {
import com.mathgames.api.remote.SWFMain;
class __forceApiImport extends SWFMain {}
}



