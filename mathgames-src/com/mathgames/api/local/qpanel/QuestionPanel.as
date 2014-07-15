package com.mathgames.api.local.qpanel
{
    import com.mathgames.api.local.*;
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.utils.*;

    final public class QuestionPanel extends EventDispatcher
    {
        static private const ANSWER_BUTTON_COUNT :int = 4;

        private var _questionRenderTarget :ScaledRenderTarget;
        private var _answerRenderTargets :Vector.<ScaledRenderTarget>;
        private var _answerClickTargets :Vector.<DisplayObject>;
        private var _answerVisibilityTargets :Vector.<DisplayObject>;

        private var _listeners :ListenerCollection = new ListenerCollection;

        private var _api :IMathGames = null;
        private var _activeQuestion :Question = null;
        private var _configured :Boolean = false;

        public function QuestionPanel (api:IMathGames)
        {
            _api = api;
        }

        static private function parseColor (color:*) :ColorTransform
        {
            if (color === undefined || color === null || !(color is uint)) return null;

            var colorU :uint = color as uint;

            var r :int = (colorU & 0xFF0000) >> 16;
            var g :int = (colorU & 0x00FF00) >> 8;
            var b :int = (colorU & 0x0000FF);
            return new ColorTransform (1, 1, 1, 1, r, g, b, 0);
        }

        public function configure (config:Object) :void
        {
            if (_configured) dispose ();

            _answerRenderTargets = new Vector.<ScaledRenderTarget>;
            _answerClickTargets = new Vector.<DisplayObject>;
            _answerVisibilityTargets = new Vector.<DisplayObject>;

            var filters :Array = [];

            if (config["question_border"] !== undefined) {
                filters.push (new GlowFilter (config["question_border"], 1, 4, 4, 20, BitmapFilterQuality.LOW, false, false));
            }

            _questionRenderTarget = new ScaledRenderTarget (config["question_area"], parseColor (config["question_color"]), filters);

            for (var i:int = 0 ; i < ANSWER_BUTTON_COUNT ; ++i)
            {
                var button:Object = config["answer_buttons"][i];

                _listeners.add (button["click_target"], MouseEvent.CLICK, answerButton_click);
                _answerRenderTargets.push (new ScaledRenderTarget (button["bounds"], parseColor (button["color"])));
                _answerClickTargets.push (button["click_target"]);
                _answerVisibilityTargets.push (button["visibility_target"]);
            }

            _listeners.add (_api, MathGamesEvent.QUESTION_READY, api_questionReady);

            _configured = true;
        }

        public function dispose () :void
        {
            _questionRenderTarget.clearAndDisable ();

            for each (var targ:ScaledRenderTarget in _answerRenderTargets) {
                targ.clearAndDisable ();
            }

            _listeners.removeAll ();
            _activeQuestion = null;
            _configured = false;
        }

        private function api_questionReady (e:MathGamesEvent) :void
        {
            var question :Question = e.data as Question;

            _questionRenderTarget.show (question.question);
            renderAnswers (question.answers);

            for (var i:int = 0; i < _answerVisibilityTargets.length; ++i) {
                if (_answerVisibilityTargets[i] != null) {
                    _answerVisibilityTargets[i].visible = i < question.answers.length;
                }
            }

            _activeQuestion = question;
        }

        private function renderAnswers (answers:Vector.<BitmapData>) :void
        {
            var minScale:Number = Number.MAX_VALUE;

            for (var i:int = 0; i < answers.length; ++i) {
                var scale:Number = _answerRenderTargets[i].getScaleRatio (answers[i]);
                if (scale < minScale) minScale = scale;
            }

            for (i = 0; i < answers.length; ++i) {
                _answerRenderTargets[i].show (answers[i], minScale);
            }
        }

        private function answerButton_click (e:MouseEvent) :void
        {
            if (_activeQuestion === null) return;

            _questionRenderTarget.clear ();
            for each (var targ:ScaledRenderTarget in _answerRenderTargets) {
                targ.clear ();
            }

            var choiceIndex :int = _answerClickTargets.indexOf (e.target);
            var correct :Boolean = choiceIndex == _activeQuestion.correctIndex;

            var answerFunc :Function = _activeQuestion.doAnswer;
            _activeQuestion = null;
            answerFunc (choiceIndex);

            dispatchEvent (new QuestionPanelEvent (QuestionPanelEvent.ANSWER, _answerClickTargets[choiceIndex], correct));
        }
    }
}
