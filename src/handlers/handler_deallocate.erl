%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 14:17
%%%-------------------------------------------------------------------
-module(handler_deallocate).
-author("SpiridonovMV").

%% API
-export([init/3,handle/2,terminate/3]).

init(_Transport, Req, Opts) ->{ok, Req, Opts}.

handle(Req, State) ->
  {Proplist,_} = cowboy_req:bindings(Req),
  Resource = proplists:get_value(resource,Proplist),
  {Method, _} = cowboy_req:method(Req),

  {ok, Resp} = maybe_answer(Resource,Method,Req),
  {ok, Resp, State}.

terminate(_Reason,_Req, _State) ->ok.

maybe_answer(undefined,_Method, Req ) ->  handler_bad_request:bad_req(Req);
maybe_answer(Resource,<<"GET">>,Req)-> answer(resp_server:deallocate(Resource),Req);
maybe_answer(_,_, Req) ->  handler_bad_request:bad_req(Req).

answer(complete, Req)->cowboy_req:reply(204, Req);
answer(_, Req)->
  cowboy_req:reply(404, [{<<"content-type">>,<<"text/plain; charset=utf-8">>}],<<"Not allocated.">>, Req).