package com.mathgames.api.local
{
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    final internal class ErrorDialog extends Sprite
    {
        static private const DIALOG_WIDTH   :Number = 360;
        static private const DIALOG_HEIGHT  :Number = 106;
        static private const DIALOG_PADDING :Number =  10;
        static private const BUTTON_TOP     :Number =  70;
        static private const BUTTON_WIDTH   :Number = 140;
        static private const BUTTON_HEIGHT  :Number =  40;
        static private const BUTTON_TEXT_Y  :Number =   8;

        // Dispatches Event.CLOSE when dismissed.

        private var _button :SimpleButton;

        public function ErrorDialog ()
        {
            this.graphics.beginFill (0xFFFFFF, 1);
            this.graphics.lineStyle (2, 0x0064A0, 1);
            this.graphics.drawRect (-DIALOG_WIDTH/2, -DIALOG_HEIGHT/2, DIALOG_WIDTH, DIALOG_HEIGHT);

            var txt:TextField = new TextField();
            txt.x = -DIALOG_WIDTH/2 + DIALOG_PADDING - 8;
            txt.y = -DIALOG_HEIGHT/2 + DIALOG_PADDING;
            txt.width = DIALOG_WIDTH - DIALOG_PADDING/2;
            txt.height = DIALOG_HEIGHT - DIALOG_PADDING/2;
            txt.selectable = false;
            txt.text = "Could not connect to MathGames";

            var fmt:TextFormat = new TextFormat();
            fmt.color = 0x529FDB;
            fmt.size = 20;
            fmt.bold = true;
            fmt.align = TextFormatAlign.CENTER
            fmt.font = "Arial";
            txt.setTextFormat(fmt);
            this.addChild(txt);

            _button = button("Try Again");
            _button.y = -DIALOG_HEIGHT/2 + BUTTON_TOP;
            this.addChild(_button);

            _button.addEventListener (MouseEvent.CLICK, tryAgain_click);
        }

        private function tryAgain_click (e:MouseEvent) :void
        {
            _button.removeEventListener (MouseEvent.CLICK, tryAgain_click);
            dispatchEvent (new Event (Event.CLOSE));
        }

        static private function button (label:String) :SimpleButton
        {
            var btn:SimpleButton = new SimpleButton;
            var main:Sprite = buttonFrame (label, 0x529FDB);
            var hover:Sprite = buttonFrame (label, 0x4688BB);
            btn.upState = main;
            btn.overState = hover;
            btn.downState = hover;
            btn.hitTestState = main;
            return btn;
        }

        static private function buttonFrame (label:String, color:uint) :Sprite
        {
            var btn:Sprite = new Sprite;
            btn.graphics.beginFill (color, 1);
            btn.graphics.drawRect (-BUTTON_WIDTH/2, -BUTTON_HEIGHT/2, BUTTON_WIDTH, BUTTON_HEIGHT);

            var txt:TextField = new TextField;
            txt.x = -btn.width/2;
            txt.y = -btn.height/2 + BUTTON_TEXT_Y;
            txt.width = btn.width;
            txt.height = btn.height - BUTTON_TEXT_Y;
            txt.selectable = false;
            txt.text = label;

            var fmt:TextFormat = new TextFormat;
            fmt.color = 0xFFFFFF;
            fmt.size = 16;
            fmt.bold = true;
            fmt.align = TextFormatAlign.CENTER
            fmt.font = "Arial";
            txt.setTextFormat(fmt);

            btn.addChild (txt);
            return btn;
        }
    }
}
