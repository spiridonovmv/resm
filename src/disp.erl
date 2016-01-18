%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 14:02
%%%-------------------------------------------------------------------
-module(disp).
-author("SpiridonovMV").

%% API
-export([rule/0, restart/0]).

restart()-> cowboy:set_env(http, dispatch,rule()).

rule()->cowboy_router:compile([
  {'_',[
    {"/allocate/:name", handler_allocate,[]},
    {"/deallocate/:resource", handler_deallocate,[]},
    {"/list", handler_list,[]},
    {"/list/:name", handler_list_for_name,[]},
    {"/reset", handler_reset,[]},

    {'_', handler_bad_request, []}
  ]}
]).
