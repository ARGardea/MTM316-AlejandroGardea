package {
	import flash.display.MovieClip;
	import flash.xml.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Dictionary;

	public class Weather2 extends MovieClip {
		var myXML: XML;
		var myLoader: URLLoader;
		var weatherIcon: MovieClip;
		
		var bigWeather: MovieClip;
		
		var centerFrameX: int;
		var centerFrameY: int;
		var bigWeatherScale: Number = .5;
		
		var draggedObject: MovieClip;
		var offsetX: Number;
		var offsetY: Number;

		var mySharedObject: SharedObject;
		var defaultCity: String = "New York City";
		var lastCity: String;
		var chosenCity: String;

		var numDays: int = 7;

		var weatherStage: MovieClip;
		var days: Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		var months: Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];


		var weatherClip: Array = [];
		var forecastNames: Array = ["Clear Skies", "Cloudy", "Raining", "Snowing", "Thunderstorm", "Fog", "Hail"];
		var animDictionary;
		var codeDictionary;

		var isDisplayMode: Boolean = false;

		public function Weather2() {
			// constructor code
			mySharedObject = SharedObject.getLocal("flashweather");
			myLoader = new URLLoader();
			processSharedObject();
			loadClips();
			loadDictionaries();
			myLoader.addEventListener(Event.COMPLETE, processXML);
			loadXML();
			
			
		}

		public function loadXML() {
			myLoader.load(new URLRequest("http://api.openweathermap.org/data/2.5/forecast/daily?q=" + chosenCity + "&mode=xml&units=imperial&cnt=7&nocache=" + new Date().time));
		}
		
		
		public function testDraggers(){
			weatherClip[0].addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
			weatherClip[0].addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		public function startDragging(event:MouseEvent){
			draggedObject = MovieClip(event.target);
			offsetX = mouseX - draggedObject.x;
			offsetY = mouseY - draggedObject.y;
			weatherStage.addChild(draggedObject);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dragClip);
		}
		
		public function dragClip(event:MouseEvent){
			draggedObject.x = mouseX - offsetX;
			draggedObject.y = mouseY - offsetY;
		}
		
		public function stopDragging(event:MouseEvent){
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragClip);
		}

		public function processCityName(target: String): String {
			var targetIndex: int = -2;

			while (targetIndex != -1) {
				if (targetIndex == -2) {
					targetIndex = target.indexOf(" ");
				} else if (targetIndex != 0 && targetIndex != target.length - 1) {
						var first: String = target.substr(0, targetIndex);
						var second: String = target.substr(targetIndex + 1, target.length - 1);

					if (target.charAt(targetIndex - 1) != '+') {
						target = first + "+" + second;
					} else {
						target = first + second;
					}
						targetIndex = target.indexOf(" ");


				} else {
					if (target != " ") {
						if (targetIndex == 0) {
							target = target.substr(targetIndex + 1, target.length);
						} else {
							target = target.substr(0, targetIndex - 1);
						}
						targetIndex = target.indexOf(" ");
					} else {
						targetIndex = -1;
					}
				}
			}

			return target;
		}

		public function processInput(event: MouseEvent) {
			if (weatherStage.CityInput.inputBox.text != "") {
				chosenCity = weatherStage.CityInput.inputBox.text;
				loadXML();
			}
		}

		public function processSharedObject() {
			if (mySharedObject.data.city != null) {
				chosenCity = mySharedObject.data.city;
			} else {
				chosenCity = defaultCity;
			}
		}

		public function saveSharedObject() {
			mySharedObject.data.city = chosenCity;
		}

		public function processDate(target: String): String {
			while (target.indexOf("-") != -1) {
				var first: String = target.substr(0, target.indexOf("-"));
				var second: String = target.substr(target.indexOf("-") + 1, target.length - 1);
				target = first + "/" + second;
			}
			target = target + " ";

			var date: Date = new Date(Date.parse(target as String));

			var dayName: String = days[date.day];
			var monthName: String = months[date.month];
			var dayNumber: int = date.date;

			target = dayName + ", " + monthName + " " + dayNumber;

			return target;
		}

		public function loadDictionaries() {
			animDictionary = new Dictionary();
			animDictionary["Clear Skies"] = 1;
			animDictionary["Cloudy"] = 2;
			animDictionary["Raining"] = 3;
			animDictionary["Snowing"] = 4;
			animDictionary["Thunderstorm"] = 5;
			animDictionary["Fog"] = 1;
			animDictionary["Hail"] = 2;
		}

		public function loadClips() {
			weatherStage = new Stage_MC;
			weatherStage.x = 0;
			weatherStage.y = 0;
			
			centerFrameX = weatherStage.width/2;
			centerFrameY = weatherStage.height/2;
			
			addChild(weatherStage);

			weatherClip[0] = weatherStage.weather0;
			weatherClip[1] = weatherStage.weather1;
			weatherClip[2] = weatherStage.weather2;
			weatherClip[3] = weatherStage.weather3;
			weatherClip[4] = weatherStage.weather4;
			weatherClip[5] = weatherStage.weather5;
			weatherClip[6] = weatherStage.weather6;
			
			for(var i:int = 0; i < 7; i++){
				weatherClip[i].addEventListener(MouseEvent.CLICK, weatherClickHandler);
			}
			
			weatherStage.Header.DisplayButton.addEventListener(MouseEvent.CLICK, clickHandler);
			weatherStage.CityInput.button.addEventListener(MouseEvent.CLICK, processInput);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
		}

		public function clickHandler(event: MouseEvent) {
			switchMode();
		}
		
		public function bigWeatherExitHandler(event: MouseEvent){
			weatherStage.removeChild(bigWeather);
		}
		
		public function bigWeatherEnterHandler(e: Event){
			if(bigWeather.y < centerFrameY){
				bigWeather.y += 40;
			}else if(bigWeather.y > centerFrameY){
				bigWeather.y = centerFrameY;
			}else{
				bigWeather.gotoAndStop(bigWeather.storedFrame);
				removeEventListener(Event.ENTER_FRAME, bigWeatherEnterHandler);
			}
		}
		
		public function weatherClickHandler(event: MouseEvent){
			
			var target:MovieClip = event.currentTarget as MovieClip;
			
			while(target.parent != weatherStage){
				target = target.parent as MovieClip;
			}
			
			if(weatherClip.indexOf(target) != -1){
				bigWeather = new bigWeather_MC;
				bigWeather.scaleX = bigWeatherScale;
				bigWeather.scaleY = bigWeatherScale;
				bigWeather.x = centerFrameX;
				bigWeather.y = 0 - bigWeather.height/2;
				
				bigWeather.exitButton.addEventListener(MouseEvent.CLICK, bigWeatherExitHandler);
				
				bigWeather.storedFrame = target.currentFrame;
				
				bigWeather.theDate.text = target.theDate.text;
				bigWeather.weather.text = target.weather.text;
				bigWeather.high.text = target.high.text;
				bigWeather.low.text = target.low.text;
				bigWeather.windSpeed.text = target.WindSpeed;
				bigWeather.windDirection.text = target.WindDirection;
				bigWeather.humidity.text = target.Humidity;				
				
				weatherStage.addChild(bigWeather);
				addEventListener(Event.ENTER_FRAME, bigWeatherEnterHandler);
			}
		}
		
		public function keyboardHandler(event: KeyboardEvent):void {
			var test:int = 3;
			if(event.ctrlKey){
				if(event.charCode == 109){
					switchMode();
				}
				/*if(event.charCode == 100){
					mySharedObject.clear();
					trace("Data Cleared");
				}*/
			}
		}
		
		public function switchMode(){
			if (isDisplayMode) {
				ReadWeather();
			} else {
				ShowWeather();
			}
		}

		public function processXML(e: Event): void {
			myXML = new XML(e.target.data);
			
			trace(myXML.*);

			if (myXML.forecast.length() > 0) {
				saveSharedObject();
				for (var i: int = 0; i < numDays; i += 1) {
					weatherClip[i].Id = myXML.forecast.time[i].symbol.@number;
					weatherClip[i].Time = processDate(myXML.forecast.time[i].@day);
					weatherClip[i].HighTemp = myXML.forecast.time[i].temperature.@max;
					weatherClip[i].LowTemp = myXML.forecast.time[i].temperature.@min;
					weatherClip[i].Forecast = myXML.forecast.time[i].symbol.@name;
					weatherClip[i].WindSpeed = myXML.forecast.time[i].windSpeed.@mps + " mps";
					weatherClip[i].WindDirection = myXML.forecast.time[i].windDirection.@name;
					weatherClip[i].Humidity = myXML.forecast.time[i].humidity.@value + myXML.forecast.time[i].humidity.@unit;
				}
				lastCity = chosenCity;
				ReadWeather();
			} else {
				weatherStage.CityLabel.text = "That city name is invalid."
				chosenCity = lastCity;
			}
		}

		public function ReadWeather() {
			/*
				1 = Sunny
				2 = Cloudy
				3 =	Raining
				4 = Snowing
				5 = Thunderstorm
			*/
			isDisplayMode = false;
			weatherStage.CityLabel.text = "Showing Forecast for: \n" + myXML.location.name + ", " + myXML.location.country;

			for (var j: int = 0; j < numDays; j += 1) {
				var wID: int = weatherClip[j].Id;

				weatherClip[j].theDate.text = weatherClip[j].Time;
				weatherClip[j].weather.text = weatherClip[j].Forecast;
				weatherClip[j].high.text = "High: " + weatherClip[j].HighTemp + "F";
				weatherClip[j].low.text = "Low: " + weatherClip[j].LowTemp + "F";

				if (wID >= 200 && wID < 300) {
					weatherClip[j].gotoAndStop(animDictionary["Thunderstorm"]);
					weatherClip[j].forecast.gotoAndPlay(1);
				} else if (wID >= 500 && wID < 600) {
					weatherClip[j].gotoAndStop(animDictionary["Raining"]);
					weatherClip[j].forecast.gotoAndPlay(1);
				} else if (wID >= 600 && wID < 700) {
					weatherClip[j].gotoAndStop(animDictionary["Snowing"]);
					weatherClip[j].forecast.gotoAndPlay(1);
				} else if (wID >= 801 && wID < 900) {
					weatherClip[j].gotoAndStop(animDictionary["Cloudy"]);
					weatherClip[j].forecast.gotoAndPlay(1);
				} else {
					weatherClip[j].gotoAndStop(animDictionary["Clear Skies"]);
					weatherClip[j].forecast.gotoAndPlay(1);
				}
			}
		}

		public function ShowWeather() {
			isDisplayMode = true;
			for (var j: int = 0; j < numDays; j += 1) {
				weatherClip[j].theDate.text = "";
				weatherClip[j].weather.text = forecastNames[j];
				weatherClip[j].high.text = "";
				weatherClip[j].low.text = "";
				
				weatherClip[j].gotoAndStop(j + 1);
				weatherClip[j].forecast.gotoAndPlay(1);
			}
		}
	}

}