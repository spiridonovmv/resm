%%%-------------------------------------------------------------------
%%% @author che
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. янв 2016 23:48
%%%-------------------------------------------------------------------
-module(http_client).
-author("che").

%% API
-export([get/1]).


get(Addr)->
  %inets:start(),
  {ok,{{_,Code,_},_,Text}} = httpc:request(get, {Addr, []}, [], []),
  {Code,Text}.