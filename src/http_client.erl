%%%-------------------------------------------------------------------
%%% @author SpiridonovMV
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. янв 2016 23:48
%%%-------------------------------------------------------------------
-module(http_client).
-author("SpiridonovMV").

%% API
-export([get/1]).


get(Addr)->
  {ok,{{_,Code,_},_,Text}} = httpc:request(get, {Addr, []}, [], []),
  {Code,Text}.