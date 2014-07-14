# MathGames Flash SDK

The Flash SDK provides a simple interface for developers to integrate the MathGames questions engine in to their Flash games.

## Events

The ``MathGames`` class implements ``EventDispatcher`` and fires events when important things happen.
Any event object dispatched by ``MathGames`` will be of type ``MathGamesEvent``.  The ``MathGamesEvent`` class
contains an instance variables called ``data`` which is used by some events to return some extra information
about what happened.

##### ``MathGamesEvent.ERROR``
This event is fired whenever an error occurs at any time during the use of the MathGames SDK. The
``data`` variable will be of type ``String`` and contain an error message describing what exactly went wrong.

##### ``MathGamesEvent.CONNECTED``
This event is fired when the MathGames Flash SDK successfully connects to the remote service.  The
``data`` variable is null for this event.

##### ``MathGamesEvent.AUTHENTICATED``
This event is fired once a player has successfully authenticated with the MathGames service and
is ready to start receiving question data.  The ``data`` variable is null for this event.

##### ``MathGamesEvent.SESSION_READY``
This event is fired after ``MathGames.instance.startSession`` is invoked, once the questions are ready and gameplay can begin. The ``data`` variable is null for this event.

##### ``MathGamesEvent.QUESTION_ANSWERED``
This event is fired whenever the player answers a question during a gameplay session.  The ``data`` variable has type ``com.mathgames.api.local.AnswerData`` and contains information about the recently answered question, including whether the answer was correct or not.

##### ``MathGamesEvent.PROGRESS_OPENED``
This event is fired after ``MathGames.instance.showProgress`` is invoked, once the panel has actually been displayed to the player. The ``data`` variable is null for this event.

##### ``MathGamesEvent.PROGRESS_CLOSED``
This event is fired after ``MathGames.instance.showProgress`` is invoked, once the panel has been dismissed and the player want to continue their play session. The ``data`` variable is null for this event.

##### ``MathGamesEvent.LOGOUT``
This event is fired when a player pressed the "Log Out" button in the game summary screen.  After this event
has been fired, ``MathGames.instance.authenticate`` **must be invoked again** before another question answering session
can begin.  The ``data`` variable is null for this event.


## Initialization

Before the questions panel can be displayed and a play session started, the game must first connect to the MathGames questions
engine and authenticate the current player.  The ``connect`` method is used to initialize the connection with the remote service.
Once this has succeeded, ``authenticate`` is used to open a panel to log the user in or determine if they want to play as a guest.

### ``connect``

```actionscript
MathGames.instance.connect
    (container:DisplayObjectContainer, // This will be the parent of the MathGames panels.
     config:Object)     // A collection of parameters used to set up the question engine.
  :void
```
The provided container must be attached to the stage when ``connect`` is invoked.  Valid options for configuration are as follows:
```actionscript
var configuration:Object = {
    "api_key": "528e1abeb4967cb32b00028e", // (REQUIRED) Specifies the API Key used to access the question service.
    "pool_key": "LEVEL_ONE", // (REQUIRED) Specifies the desired default question pool.
    "log_func": trace // (OPTIONAL) A function expecting a string which will be invoked with debug messages.
}
```
Once the MathGames service connection has successfully been established, ``MathGamesEvent.CONNECTED`` is fired.

### ``authenticate``

```actionscript
MathGames.instance.authenticate () :void
```
Opens an authentication panel in order to log the player in. Once the player has been authenticated ``MathGamesEvent.AUTHENTICATED`` is fired.



### Session Management

A game using the MathGames service consists of a series of play sessions where questions are presented to the player one after the other.  Play sessions happen between a call to ``startSession`` and a call to ``endSession``.  Once the player has reached a milestone, such as completing a level, ``showProgress`` is invoked to get some summary information about the player's progress.

### ``startSession``

```actionscript
MathGames.instance.startSession
    (config:Object)  // A collection of parameters used to configure the next play session.
  :void
```

This method accepts a configuration object, and a callback function which is invoked when the questions are ready
and the gameplay session can begin.  If everything goes smoothly, the MathGames instance will fire ``MathGamesEvent.SESSION_READY``.

Valid options for configuration are as follows:

```actionscript
var configuration:Object = {
    "pool_key": "LEVEL_ONE", // (OPTIONAL) Specifies the desired question pool to use for this session.
                             // If none is provided then the previously specified one is used.
    "clear_progress": true, // (OPTIONAL) Clears accumulated progress which is viewed in the showProgress screen.
    "question_panel": { // (OPTIONAL) Configuration for using a custom question panel.
        "question_area": someDisplayObject, // Specifies a custom area to place the question.
        "question_color": 0xRRGGBB,         // Color used to render the question, default black.
        "answer_buttons": [
            { "bounds": someDisplayObject, // (REQUIRED) The region where the answer should be rendered.
              "click_target": someDisplayObject, // (REQUIRED) A DisplayObject which receives click events for this answer.
              "visibility_target": someDisplayObject, // (REQUIRED) If there are fewer than 4 answers, this object has its visibility set to false for the unneeded answers.
              "color": 0xRRGGBB }, // (OPTIONAL) Color to render answers on this button, default black.
            { ... },
            { ... },
            { ... }
        ]
    }
}
```

### Setting up custom question regions and answer buttons

**TODO** This section will contain information on how to set up the ``someDisplayObject`` references above.  For now please reference the SampleGame project to see how the custom question area is constructed.

### ``endSession``

```actionscript
MathGames.instance.endSession () :void
```

This method accepts no parameters and returns nothing.  You can assume that, immediately after calling ``endSession``, the session is complete.  You can then show menus, cutscenes, or anything related to the game which is not part of the question-answering sessions.  Once ``endSession`` is called, any references to display objects provided in "startSession" are cleared.

### ``showProgress``

```actionscript
MathGames.instance.showProgress () :void
```

The ``showProgress`` method pops up a summary panel showing the progressions and skills which the player has accumulated since the previous call to ``showProgress``.  It should be called when the player reaches a milestone in the game, such as completing a level, and it's appropriate to show some summarizing information about the player's progress so far.
After a call to ``showProgress`` the SDK must communicate with the MathGames service.  This means that the summary panel won't show up right away.  When the required information is returned from the service, and the summary panel shows up, ``MathGamesEvent.PROGRESS_OPENED`` will be fired.  When the player closes the summary panel and is ready to play another round of the game, ``MathGamesEvent.PROGRESS_CLOSED`` is fired.  If the player chooses to log out of the MathGames service instead of continuing with their play session, ``MathGamesEvent.LOGOUT`` will be fired, and ``MathGames.instance.authenticate`` will have to be called again before starting another play session.

### ``showSupportedSkillStandards``

```actionscript
MathGames.instance.showSupportedSkillStandards () :void
```

Displays a list of all curriculum mappings supported by the MathGames SDK, and highlights the ones supported by the current game.

### ``postMetrics``

```actionscript
MathGames.instance.postMetrics
    (key:String,
     data:Object)
  :void
```

Post custom metrics events to the MathGames server.


### ``setSoundEnabled``

```actionscript
MathGames.instance.setSoundEnabled
    (enabled:Boolean)
  :void
```

Toggles built-in sounds in the MathGames SDK screens.

