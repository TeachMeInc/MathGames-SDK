package com.mathgames.api.local.qpanel
{
    import flash.events.*;

    final internal class ListenerCollection
    {
        private var _listeners :Vector.<SingleListener>;

        public function ListenerCollection ()
        {
            _listeners = new Vector.<SingleListener>;
        }

        public function add (target:IEventDispatcher, eventName:String, listener:Function, weak:Boolean=false) :void
        {
            _listeners.push (new SingleListener (target, eventName, listener, weak));
        }

        public function remove (target:IEventDispatcher=null, eventName:String=null, listener:Function=null) :void
        {
            if (target === null && eventName === null && listener === null) {
                removeAll ();
                return;
            }

            for (var i:int = 0; i < _listeners.length; ++i) {
                if (_listeners[i].matches (target, eventName, listener)) {
                    _listeners[i].remove ();
                    _listeners.splice (i, 1);
                    break;
                }
            }
        }

        public function removeAll () :void
        {
            while (_listeners.length > 0) {
                _listeners.pop().remove();
            }
        }
    }
}

import flash.events.*;

class SingleListener
{
    private var target    :IEventDispatcher;
    private var eventName :String;
    private var listener  :Function;

    public function SingleListener (target:IEventDispatcher, eventName:String, listener:Function, weak:Boolean=true)
    {
        this.target = target;
        this.eventName = eventName;
        this.listener = listener;

        target.addEventListener (eventName, listener, false, 0, weak);
    }

    public function matches (target:IEventDispatcher=null, eventName:String=null, listener:Function=null) :Boolean
    {
        var match:Boolean = true;
        if (target !== null) match &&= this.target === target;
        if (eventName !== null) match &&= this.eventName === eventName;
        if (listener !== null) match &&= this.listener === listener;
        return match;
    }

    public function remove () :void
    {
        target.removeEventListener (eventName, listener);
    }
}
