-module(ring).
-export([create/2, start/1, loop/1]).

create(Count, Message) ->
	Pid = spawn(ring, start, [Message]),
	create(Count - 1, [Pid], Pid).

create(0, [Prev | Rest], First) ->
	First ! Prev,
	Ring = [Prev | Rest],
	lists:reverse(Ring);

create(Count, [Prev | Rest], First) ->
	Pid = spawn(ring, loop, [Prev]),
	create(Count - 1, [Pid , Prev | Rest], First).

start(Message) ->
	receive
		Next ->
			Next ! Message,
			loop(Next)
	end.

loop(Next) ->
	receive
		Message ->
			io:format("~p: ~s~n", [self(), Message]),
			Next ! Message,
			loop(Next)
	end.
