%%%-------------------------------------------------------------------
%%% @author SpiridonovMV
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. янв 2016 3:25
%%%-------------------------------------------------------------------
-module(basic_SUITE).
-author("SpiridonovMV").

-compile(export_all).
%% API
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

all() ->
  [
    {group, http},
    {group, resm_server}
  ].

groups() ->
  [
    {http, [inorder], [tz_story,tz_bad]},
    {resm_server, [inorder], [tz_story_server]}
  ].

init_per_group(http, Config) ->
  resm:start(),
  inets:start(),
  Config;
init_per_group(resm_server, Config) ->
  resm_server:start_link(),
  Config;

init_per_group(_, Config) -> Config.

end_per_group(http, Config)->
  spawn({resm,stop}),
  inets:stop(),
  Config;

end_per_group(resm_server, Config)->
  resm_server:stop(),
  Config;

end_per_group(_, Config)-> Config.


tz_bad(_Config)->
  ?assertEqual(
    {400,"Bad request."},
    http_client:get("http://127.0.0.1:8080/allocate/")
  ).

tz_story(_Config)->
    ?assertEqual(
      {204,[]},
      http_client:get("http://127.0.0.1:8080/reset")
    ),
    ?assertEqual(
      {200,"{\"allocated\":{},\"deallocated\":[\"r1\",\"r2\",\"r3\",\"r4\",\"r5\"]}"},
      http_client:get("http://127.0.0.1:8080/list")
    ),
    ?assertEqual(
      {200,"[]"},
      http_client:get("http://127.0.0.1:8080/list/bob")
    ),
    ?assertEqual(
      {201,"r1"},
      http_client:get("http://127.0.0.1:8080/allocate/alice")
    ),
    ?assertEqual(
      {201,"r2"},
      http_client:get("http://127.0.0.1:8080/allocate/alice")
    ),
    ?assertEqual(
      {201,"r3"},
      http_client:get("http://127.0.0.1:8080/allocate/bob")
    ),
    ?assertEqual(
      {201,"r4"},
      http_client:get("http://127.0.0.1:8080/allocate/alice")
    ),
    ?assertEqual(
      {201,"r5"},
      http_client:get("http://127.0.0.1:8080/allocate/alice")
    ),
    ?assertEqual(
      {503,"Out of resources."},
      http_client:get("http://127.0.0.1:8080/allocate/bob")
    ),
    ?assertEqual(
      {204,[]},
      http_client:get("http://127.0.0.1:8080/deallocate/r1")
    ),
    ?assertEqual(
      {404,"Not allocated."},
      http_client:get("http://127.0.0.1:8080/deallocate/r1")
    ),
    ?assertEqual(
      {404,"Not allocated."},
      http_client:get("http://127.0.0.1:8080/deallocate/any")
    ),
    ?assertEqual(
      {200,"{\"allocated\":{\"r2\":\"alice\",\"r3\":\"bob\",\"r4\":\"alice\",\"r5\":\"alice\"},\"deallocated\":[\"r1\"]}"},
      http_client:get("http://127.0.0.1:8080/list")
    ),
    ?assertEqual(
      {200,"[\"r2\",\"r4\",\"r5\"]"},
      http_client:get("http://127.0.0.1:8080/list/alice")
    ),
    ?assertEqual(
      {204,[]},
      http_client:get("http://127.0.0.1:8080/reset")
    ),
    ?assertEqual(
      {400,"Bad request."},
      http_client:get("http://127.0.0.1:8080/something")
    ).

tz_story_server(_Config)->
  ?assertEqual(ok,fun()-> resm_server:reset() end()),
  ?assertEqual({5,[],[<<"r1">>,<<"r2">>,<<"r3">>,<<"r4">>,<<"r5">>]},fun()-> resm_server:status() end()),
  ?assertEqual(<<"[]">>,fun()-> resm_server:list(<<"bob">>) end()).