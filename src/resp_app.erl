-module(resp_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->


  resp_sup:start_link(),

  {ok, _} = cowboy:start_http(http, 300,
    [{port, application:get_env(resp,http_port, 8080)}],
    [
      {env, [{dispatch, disp:rule()}]},
      {timeout, 2000}
    ]).
stop(_State) ->
    ok.
