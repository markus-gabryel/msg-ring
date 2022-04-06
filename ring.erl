-module(ring).
-export([launch/3, create/3, first_loop/2, loop/1]).

% Launch the creation chain
launch(Count, Message, Times) ->
	Pid = spawn(ring, first_loop, [Message, Times]),
	create(Count - 1, [Pid], Pid).

% If the creation count is done
create(0, [Prev | Rest], First) ->
	First ! Prev,
	Ring = [Prev | Rest],
	lists:reverse(Ring);

% Just create another process
create(Count, [Prev | Rest], First) ->
	Pid = spawn(ring, loop, [Prev]),
	create(Count - 1, [Pid , Prev | Rest], First).

% Wait for the last process created
first_loop(Message, Count) ->
	receive
		Next ->
			% Start to forward the message
			Next ! {Message, Count},
			loop(Next)
	end.

loop(Next) ->
	receive
		% If the forwarding count is done
		{Message, 1} ->
			% Print the message
			io:format("* ~p: ~s~n", [self(), Message]),
			loop(Next);

		% If Count =/= 1
		{Message, Count} ->
			% Just forward the message
			io:format("* ~p~n", [self()]),
			Next ! {Message, Count - 1},
			loop(Next)
	end.


