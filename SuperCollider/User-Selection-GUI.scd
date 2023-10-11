// =====================================================================
// SuperCollider Workspace
// =====================================================================
//


(
var w, menu, snd, funcs, b;
~select = ();
w = Window.new.front;

menu = PopUpMenu(w, Rect(10, 10, 90, 20))
.items_(~dict.keys.asArray);

funcs = ~dict.values.asArray;

b = Button(w, Rect(110, 10, 180, 20))
.states_([["select", Color.black, Color.green]])
.mouseDownAction_({
    snd = funcs.at(menu.value);
})
.action_({ arg butt, mod;
	~select = snd.postln;
});

w.front;

p = CmdPeriod.add({ b.value_(0) }); // set button to 0 on hitting Cmd-period
w.onClose_{ snd.release; CmdPeriod.removeAll }; // clean up when window is closed
)