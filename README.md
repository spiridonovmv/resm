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
    
Docker
-----

This project contained Dockerfile for built and run Docker image.

    build       % sudo docker build --tag=spiridonovmv/resm:latest ./
    test & run  % sudo docker run -it --rm -p 8080:8080 spiridonovmv/resm:latest make shell
    run         % sudo docker run -it --rm -p 8080:8080 spiridonovmv/resm:latest  
    
*warning* port in run command and http_port in resm.config must be equal.

You can run this image as service: 

    sudo docker run -d -p 8080:8080 spiridonovmv/resm:latest

Credits
-------

* Mikhail Spiridonov