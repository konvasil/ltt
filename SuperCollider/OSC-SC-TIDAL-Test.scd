n = NetAddr("localhost", 6010);
n.sendMsg('/ctrl', 'speed', Array.fill(4, {rrand(0.1, 1.0).round(0.01)})); //this not okay
n.sendMsg('/unmute', 1); //this okay

-- tidal code
(cP "1 2 3 4" "speed" |/ 0.5)



(
Tdef(\tidal, {
	loop{
		1.wait;
~string = "<";
4.collect { ~string = ~string ++ 100.rand2.max(1.0).round(0.01).asString  ++ " ";};
~string = ~string ++ ">";
		n.sendMsg('/ctrl', 'speed', ~string);
}.fork;
}).play
)
