RESM for machinezone
========================



Supported Methods
-----------------

* Allocate
* Deallocate
* List
* Reset

How usage
---

    make clean      % Clean projects. Remove binary, logs and other trash.
    make            % Load deps, build project, run test
    make run        % Run application without test
    make shell      % Run application with test
    make ct         % Run tests.


Configure
-----

You can find all config in (PROJECT_ROOT/)resm.config 

    [
      %% Change the values ​​of your choice
      {resp,
        [
          {count_resources,5}, % The amount of available resources
          {http_port,8080} % You can set a specific port to listen
        ]
      },
      %% Don't change next section!
      {sasl,
        [
          {sasl_error_logger, false},
          {errlog_type, error},
          {error_logger_mf_dir,"/opt/error_logs" },
          {error_logger_mf_maxbytes,104857600}, % 100 MB
          {error_logger_mf_maxfiles, 10}
        ]
      }
    ].
    


Credits
-------

* Mikhail Spiridonov