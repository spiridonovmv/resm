-module(resm_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->


  resm_sup:start_link(),

  {ok, _} = cowboy:start_http(http, 300,
    [{port, application:get_env(resm,http_port, 8080)}],
    [
      {env, [{dispatch, disp:rule()}]},
      {timeout, 2000}
    ]).
stop(_State) ->
    ok.
