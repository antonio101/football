# Football

This is a JSON API developed in Elixir that provides you some information about football matches stored in a CSV file.
Mainly, you can make nexts requests:
- To get a list of leagues and seasons on we have results of their matches stored.
- To get results of an specific league and season pair.

### CSV file

By default, we have to save our CSV file, called **Data.csv**, on the root folder of the project. The scructure must be a CSV separated with commas and with the headings and content like the next example:

|  | Div | Season | Date | HomeTeam | AwayTeam | FTHG | FTAG | FTR | HTHG | HTAG | HTR |
| ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| 1 | SP1 | 201617 | 19/08/2016 | La Coruna | Eibar | 2 | 1 | H | 0 | 0 | D | 

### Run it on your machine

Football requires **elixir 1.8** and erlang **21.1** to run.
We only have to get all dependences and run the application:

```sh
$ mix deps.get
$ iex -S mix
```


## API
### Calls

The requests have to be called via http://localhost:4001.
#### Leagues and seasons pairs:
| Title |  Description | 
| ------ |  ------ | 
| Call description |  Get a list of leagues and seasons on we have results of their matches stored. | 
| URL |  /pairs | 
| Method: |  GET | 
| Data Params |  None | 
| Response |  [{"div":"D1","name":"Bundesliga 2016-2017","season":"201617"},{"div":"E0","name":"Premier League 2016-2017","season":"201617"}] | 

#### League and season results:
| Title |  Description | 
| ------ |  ------ | 
| Call description |  Get a list of results for a specific league and season pair. | 
| URL |  /leagues | 
| Method: |  GET | 
| Data Params |  div (required)<br>season (required)<br>`Example: div=SP2&season=201617` | 
| Response |  [{"AwayTeam":"Getafe","Date":"12/05/2017","FTAG":"1","FTHG":"2","FTR":"H","HTAG":"0","HTHG":"1","HTR":"H","HomeTeam":"Sevilla B"}] | 

### Status Codes

Football returns the following status codes in its API:

| Status Code | Description |
| :--- | :--- |
| 200 | `OK` |
| 404 | `NOT FOUND` |
| 500 | `INTERNAL SERVER ERROR` |


## Launch with Docker

```sh
# docker login
# docker pull "antonio101/football"
# docker run -it -p 4001:4001 antonio101/football:latest
```

