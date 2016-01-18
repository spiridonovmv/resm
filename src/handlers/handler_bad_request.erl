%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 14:17
%%%-------------------------------------------------------------------
-module(handler_bad_request).
-author("che").

%% API
-export([init/3,handle/2,terminate/3]).
-export([bad_req/1]).

init(_Transport, Req, Opts) ->{ok, Req, Opts}.

handle(Req, State) ->
  {Method, _} = cowboy_req:method(Req),
  io:format("~62p~n",[{Method}]),
  {ok, Resp} = bad_req(Req),
  {ok, Resp, State}.

terminate(_Reason,_Req, _State) ->ok.

bad_req(Req) -> cowboy_req:reply(400,[{<<"content-type">>,<<"text/plain; charset=utf-8">>}],<<"Bad request.">>,Req).

