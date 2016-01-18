%%%-------------------------------------------------------------------
%%% @author Spiridonov Mikhail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. янв 2016 14:46
%%%-------------------------------------------------------------------
-module(resp_server).
-author("che").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([
  allocate/1,
  deallocate/1,
  list/1,
  reset/0,
  stop/0,
  status/0
]).


%%%===================================================================
%%% API
%%%===================================================================

allocate(Name)-> gen_server:call(resp_server,{allocate,Name}).
deallocate(Resource)-> gen_server:call(resp_server,{deallocate,Resource}).
list(Name)-> gen_server:call(resp_server,{list,Name}).
reset()-> gen_server:call(resp_server,reset).

stop()->gen_server:cast(resp_server,stop).
status()->gen_server:call(resp_server,status).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() -> {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() -> gen_server:start_link({local, resp_server}, resp_server, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) -> {ok,  term()} | {ok,  term(), timeout() | hibernate} | {stop, Reason :: term()} | ignore).
init([]) ->
  Ets = ets:new(resp_ets,[ordered_set,private]),
  gen_server:cast(resp_server,init),
  {ok, Ets}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: term()) ->
  {reply, Reply :: term(), NewState ::  atom()} |
  {reply, Reply :: term(), NewState ::  atom(), timeout() | hibernate} |
  {noreply, NewState ::  atom()} |
  {noreply, NewState ::  atom(), timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState ::  atom()} |
  {stop, Reason :: term(), NewState ::  atom()}).


handle_call({allocate,Name},_,State)->
  First_empty_resource = ets:match(State,{'$1',empty},1),
  {reply, allocate_priv(Name,First_empty_resource,State), State};

handle_call({deallocate,Resource},_,State)->
  Name = ets:match(State,{Resource,'$1'}),
  {reply, deallocate_priv(Resource,Name,State), State};


handle_call({list,all},_,State)->
  Allocated = ets:select(State,[{{'$1','$2'},[{'/=','$2',empty}],['$_']}]),
  Deallocated  = lists:flatten(ets:match(State,{'$1',empty})),
  {reply, jsx:encode([{<<"allocated">>,list_priv(Allocated)},{<<"deallocated">>,Deallocated}]), State};

handle_call({list,Name},_,State)->
  Resources = ets:match(State,{'$1',Name}),
  {reply, jsx:encode(lists:flatten(Resources)), State};

handle_call(reset,_,State)->
  {reply, reset_priv(State), State};

handle_call(status,_,State)->
  Count = application:get_env(resp,count_resources,5),
  Allocated = ets:select(State,[{{'$1','$2'},[{'/=','$2',empty}],['$_']}]),
  Deallocated  = lists:flatten(ets:match(State,{'$1',empty})),
  {reply, {Count,Allocated,Deallocated}, State};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: term()) ->
  {noreply, NewState ::  atom()} |
  {noreply, NewState ::  atom(), timeout() | hibernate} |
  {stop, Reason :: term(), NewState ::  atom()}).

handle_cast(init,  State)->
  reset_priv(State),
  {noreply,  State};

handle_cast(stop, State) ->
  {stop, normal, State};

handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: term()) ->
  {noreply, NewState ::  atom()} |
  {noreply, NewState ::  atom(), timeout() | hibernate} |
  {stop, Reason :: term(), NewState ::  atom()}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: term()) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: term(),
    Extra :: term()) ->
  {ok, NewState ::  atom()} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

list_priv([])-> [{}];
list_priv(A)->A.

reset_priv(Ets)->
  ets:delete_all_objects(Ets),
  Count = application:get_env(resp,count_resources,5),
  Keys = [list_to_binary([<<"r">>,integer_to_list(N)])||N<-lists:seq(1,Count)],
  [ets:insert(Ets,{Key,empty})||Key <- Keys],
  ok.

allocate_priv(Name,{[[Resource]],_},Ets)->
  ets:insert(Ets, {Resource,Name}),
  {created,Resource};
allocate_priv(_Name,_,_Ets)-><<"Out of resources.">>.

deallocate_priv(Resource,[[Name]],Ets) when Name =/= empty->
  ets:insert(Ets, {Resource,empty}),
  complete;
deallocate_priv(_Resource,_,_Ets)-><<"Not allocated.">>.