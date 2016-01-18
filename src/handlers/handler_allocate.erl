%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 14:17
%%%-------------------------------------------------------------------
-module(handler_allocate).
-author("SpiridonovMV").

%% API
-export([init/3,handle/2,terminate/3]).

init(_Transport, Req, Opts) ->{ok, Req, Opts}.

handle(Req, State) ->
  {Proplist,_} = cowboy_req:bindings(Req),
  Name = proplists:get_value(name,Proplist),
  {Method, _} = cowboy_req:method(Req),

  {ok, Resp} = maybe_answer(Name,Method,Req),
  {ok, Resp, State}.

terminate(_Reason,_Req, _State) ->ok.

maybe_answer(undefined,_Method, Req ) ->  handler_bad_request:bad_req(Req);
maybe_answer(Name,<<"GET">>,Req)-> answer(resm_server:allocate(Name),Req);
maybe_answer(_,_, Req) ->  handler_bad_request:bad_req(Req).

answer({created,Resource}, Req)->cowboy_req:reply(201, [{<<"content-type">>,<<"text/plain; charset=utf-8">>}],Resource, Req);
answer(_, Req)->
  cowboy_req:reply(503, [{<<"content-type">>,<<"text/plain; charset=utf-8">>}],<<"Out of resources.">>, Req).