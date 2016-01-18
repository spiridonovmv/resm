%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 14:17
%%%-------------------------------------------------------------------
-module(handler_reset).
-author("che").

%% API
-export([init/3,handle/2,terminate/3]).

init(_Transport, Req, Opts) ->{ok, Req, Opts}.

handle(Req, State) ->
  {Method, _} = cowboy_req:method(Req),

  io:format("~62p~n",[{Method}]),
  {ok, Resp} = maybe_answer(Method,Req),
  {ok, Resp, State}.

terminate(_Reason,_Req, _State) ->ok.


maybe_answer(<<"GET">>,Req)-> resp_server:reset(),cowboy_req:reply(204, Req);
maybe_answer(_, Req) ->  handler_bad_request:bad_req(Req).