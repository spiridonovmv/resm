%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 13:56
%%%-------------------------------------------------------------------
-module(resp).
-author("che").

%% API
-export([start/0]).

%% @doc Запуск crypto, cowboy, bson, mongodb, ec в указанном порядке.
start() ->
  ok = application:ensure_started(asn1),
  ok = application:ensure_started(crypto),
  ok = application:ensure_started(ranch),
  ok = application:ensure_started(cowlib),
  ok = application:ensure_started(public_key),
  ok = application:ensure_started(ssl),
  ok = application:ensure_started(cowboy),
  ok = application:ensure_started(resp).

