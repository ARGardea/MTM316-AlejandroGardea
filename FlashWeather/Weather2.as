package {
	import flash.display.MovieClip;
	import flash.xml.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.Dictionary;
	import flash.display.SimpleButton;

	public class Weather2 extends MovieClip {
		var myXML: XML;
		var myLoader: URLLoader;
		var weatherIcon: MovieClip;

		var bigWeather: MovieClip;

		var centerFrameX: int;
		var centerFrameY: int;
		var bigWeatherScale: Number = .5;

		var resizedObject: MovieClip;
		var draggedObject: MovieClip;
		var offsetX: Number;
		var offsetY: Number;

		var defaultWeatherX: Array = [];
		var defaultWeatherY: Array = [];
		var defaultWeatherHeight: Array = [];
		var defaultWeatherWidth: Array = [];

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
		
		public function loadResizers() {
			for (var i: int = 0; i < numDays; i++){
				weatherClip[i].dragButton.addEventListener(MouseEvent.MOUSE_DOWN, startResizing);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopResizing);
			}
		}

		public function loadDraggers() {
			for (var i: int = 0; i < numDays; i++) {
				weatherClip[i].moveButton.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
				weatherClip[i].moveButton.addEventListener(MouseEvent.MOUSE_UP, stopDragging);

				//weatherClip[i].dragButton2.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
				//weatherClip[i].dragButton2.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			}
		}

		public function startResizing(event: MouseEvent) {
			trace("resize start!");
			var clickTarget = event.currentTarget as SimpleButton;
			resizedObject = MovieClip(clickTarget.parent);
			offsetX = (resizedObject.width) - mouseX;
			offsetY = (resizedObject.height) - mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, resizeClip);
		}
		
		public function stopResizing(event: MouseEvent){
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeClip);
		}
		
		public function resizeClip(event: MouseEvent){
			var heightDifference: Number = mouseY - (resizedObject.y + resizedObject.height);
			var heightScale: Number = heightDifference / resizedObject.animBackground.height;
			var widthDifference: Number = mouseX - (resizedObject.x + resizedObject.width);
			var widthScale: Number = widthDifference / resizedObject.animBackground.width;
			
			// var heightDiff: Number = wantedHeight - tempClip.height;
			// var scalePercent: Number = heightDiff / tempClip.height;
			
			var targetDifference: Number = heightDifference;
			var targetScale: Number = heightScale;
			
			if(targetDifference < widthDifference){
				targetDifference = widthDifference;
				targetScale = widthScale;
			}
			trace("Height difference is " + heightDifference);
			trace("Width difference is " + widthDifference);
			trace("Target scale is " + targetScale);
			resizedObject.height += (targetScale*resizedObject.animBackground.height);
			resizedObject.width += (targetScale*resizedObject.animBackground.width);
		}

		public function startDragging(event: MouseEvent) {
			var clickTarget = event.currentTarget as SimpleButton;
			draggedObject = MovieClip(clickTarget.parent);
			offsetX = mouseX - draggedObject.x;
			offsetY = mouseY - draggedObject.y;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dragClip);
		}

		public function dragClip(event: MouseEvent) {
			draggedObject.x = mouseX - offsetX;
			draggedObject.y = mouseY - offsetY;
		}

		public function stopDragging(e: MouseEvent) {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragClip);
			saveClipProperties();
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
			readInput();
		}

		public function readInput() {
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

		public function generateClips() {
			var dataFound: Boolean = (mySharedObject.data.defaultWeatherX != undefined);
			if (dataFound) {
				defaultWeatherX = mySharedObject.data.defaultWeatherX;
				defaultWeatherY = mySharedObject.data.defaultWeatherY;
				defaultWeatherHeight = mySharedObject.data.defaultWeatherHeight;
				defaultWeatherWidth = mySharedObject.data.defaultWeatherWidth;
			}
			for (var i: int = 0; i < numDays; i++) {
				weatherClip[i] = new Weather_Anim_MC();
				var tempClip: MovieClip = weatherClip[i];
				setClipPropertiesToDefault(i);
				/*if(i == 0){
					var wantedHeight: Number = weatherStage.height/2;
					var heightDiff: Number = wantedHeight - tempClip.height;
					var scalePercent: Number = heightDiff/tempClip.height;
					tempClip.scaleX += scalePercent;
					tempClip.scaleY += scalePercent;
					tempClip.x = (weatherStage.width/2) - (tempClip.width/2);
					tempClip.y = wantedHeight - ((tempClip.height/6)*5);
				}else{
					var wantedWidth: Number = weatherStage.width/(numDays);
					var widthPercent: Number = wantedWidth/tempClip.width;
					tempClip.scaleX = widthPercent;
					tempClip.scaleY = widthPercent;
					tempClip.y = weatherStage.height - tempClip.height;
					tempClip.x = (wantedWidth*i) - tempClip.height/2 + ((tempClip.height/20)*i);
				}*/
				if (dataFound) {
					loadClipPropertiesByIndex(i);
				}
				weatherStage.addChild(tempClip);
			}
		}
		
		public function resetClipProperties(){
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopResizing);
			for (var j: int = 0; j < numDays; j++){
				weatherStage.removeChild(weatherClip[j]);
			}
			for (var i: int = 0; i < numDays; i++) {
				weatherClip[i] = new Weather_Anim_MC();
				var tempClip: MovieClip = weatherClip[i];
				setClipPropertiesToDefault(i);
				weatherStage.addChild(tempClip);
			}
			loadDraggers();
			loadResizers();
			this.rereadXML();
		}

		public function setClipPropertiesToDefault(i: int) {
			var tempClip: MovieClip = weatherClip[i];
			if (i == 0) {
				var wantedHeight: Number = weatherStage.height / 2;
				var heightDiff: Number = wantedHeight - tempClip.height;
				var scalePercent: Number = heightDiff / tempClip.height;
				trace("scalePercent is " + scalePercent);
				trace(tempClip.height);
				trace(tempClip.width);
				tempClip.scaleX += scalePercent;
				tempClip.scaleY += scalePercent;
				trace(tempClip.height);
				trace(tempClip.width);
				/*if(scalePercent > 0){
						tempClip.width *= scalePercent;
						tempClip.height *= scalePercent;
						trace("Percent is positive");
					}else{
						tempClip.width /= scalePercent;
						tempClip.height /= scalePercent;
						trace("Percent is negative");
					}*/
				//tempClip.scaleX += scalePercent;
				//tempClip.scaleY += scalePercent;
				tempClip.x = (weatherStage.width / 2) - (tempClip.width / 2);
				tempClip.y = wantedHeight - ((tempClip.height / 6) * 5);
			} else {
				var wantedWidth: Number = weatherStage.width / (numDays);
				var widthPercent: Number = wantedWidth / tempClip.width;
				trace(tempClip.height);
				trace(tempClip.width);
				//tempClip.width *= widthPercent;
				//tempClip.height *= widthPercent;
				tempClip.scaleX = widthPercent;
				tempClip.scaleY = widthPercent;
				trace(tempClip.height);
				trace(tempClip.width);
				tempClip.y = weatherStage.height - tempClip.height;
				tempClip.x = (wantedWidth * i) - tempClip.height / 2 + ((tempClip.height / 20) * i);
			}
		}

		public function setDefaultClipProperties() {
			for (var i: int = 0; i < numDays; i++) {
				var tempClip: MovieClip = weatherClip[i];
				if (i == 0) {
					var wantedHeight: Number = weatherStage.height / 2;
					var heightDiff: Number = wantedHeight - tempClip.height;
					var scalePercent: Number = heightDiff / tempClip.height;
					tempClip.scaleX += scalePercent;
					tempClip.scaleY += scalePercent;
					tempClip.x = (weatherStage.width / 2) - (tempClip.width / 2);
					tempClip.y = wantedHeight - ((tempClip.height / 6) * 5);
				} else {
					var wantedWidth: Number = weatherStage.width / (numDays);
					var widthPercent: Number = wantedWidth / tempClip.width;
					tempClip.scaleX = widthPercent;
					tempClip.scaleY = widthPercent;
					tempClip.y = weatherStage.height - tempClip.height;
					tempClip.x = (wantedWidth * i) - tempClip.height / 2 + ((tempClip.height / 20) * i);
				}
			}
		}

		public function loadClipPropertiesByIndex(i: int) {
			var tempClip: MovieClip = weatherClip[i];
			tempClip.x = defaultWeatherX[i];
			tempClip.y = defaultWeatherY[i];
			tempClip.height = defaultWeatherHeight[i];
			tempClip.width = defaultWeatherWidth[i];
			trace("Properties for clip " + i);
			trace("X: " + tempClip.x);
			trace("Y: " + tempClip.y);
			trace("Height: " + tempClip.height);
			trace("Width: " + tempClip.width);
		}

		public function loadClipProperties() {
			defaultWeatherX = mySharedObject.data.defaultWeatherX;
			defaultWeatherY = mySharedObject.data.defaultWeatherY;
			defaultWeatherHeight = mySharedObject.data.defaultWeatherHeight;
			defaultWeatherWidth = mySharedObject.data.defaultWeatherWidth;

			for (var i: int = 0; i < numDays; i++) {
				var tempClip: MovieClip = weatherClip[i];
				tempClip.x = defaultWeatherX[i];
				tempClip.y = defaultWeatherY[i];
				tempClip.height = defaultWeatherHeight[i];
				tempClip.width = defaultWeatherWidth[i];
			}
		}

		public function saveClipProperties() {
			for (var i: int = 0; i < numDays; i++) {
				var tempClip: MovieClip = weatherClip[i];
				defaultWeatherX[i] = tempClip.x
				defaultWeatherY[i] = tempClip.y
				defaultWeatherHeight[i] = tempClip.animBackground.height*tempClip.scaleY;
				defaultWeatherWidth[i] = tempClip.animBackground.width*tempClip.scaleX;
				trace("Saving Properties for clip " + i);
				trace("X: " + tempClip.x);
				trace("Y: " + tempClip.y);
				trace("Height: " + tempClip.animBackground.height*tempClip.scaleY);
				trace("Width: " + tempClip.animBackground.width*tempClip.scaleX);
			}
			mySharedObject.data.defaultWeatherX = defaultWeatherX;
			mySharedObject.data.defaultWeatherY = defaultWeatherY;
			mySharedObject.data.defaultWeatherHeight = defaultWeatherHeight;
			mySharedObject.data.defaultWeatherWidth = defaultWeatherWidth;
			mySharedObject.flush();
		}

		public function loadClips() {
			weatherStage = new Stage_MC;
			weatherStage.x = 0;
			weatherStage.y = 0;



			centerFrameX = weatherStage.width / 2;
			centerFrameY = weatherStage.height / 2;

			bigWeather = new bigWeather_MC;

			addChild(weatherStage);

			generateClips();

			/*weatherClip[0] = weatherStage.weather0;
			weatherClip[1] = weatherStage.weather1;
			weatherClip[2] = weatherStage.weather2;
			weatherClip[3] = weatherStage.weather3;
			weatherClip[4] = weatherStage.weather4;
			weatherClip[5] = weatherStage.weather5;
			weatherClip[6] = weatherStage.weather6;*/

			for (var i: int = 0; i < 7; i++) {

				weatherClip[i].targetButton.addEventListener(MouseEvent.CLICK, weatherClickHandler);
			}

			weatherStage.Header.DisplayButton.addEventListener(MouseEvent.CLICK, clickHandler);
			weatherStage.Header.RefreshButton.addEventListener(MouseEvent.CLICK, refreshClickHandler);
			weatherStage.Header.resetDimensionsButton.addEventListener(MouseEvent.CLICK, resetDimensionsHandler);
			weatherStage.CityInput.button.addEventListener(MouseEvent.CLICK, processInput);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);

			loadDraggers();
			loadResizers();
		}
		
		public function resetDimensionsHandler(e: MouseEvent){
			resetClipProperties();
		}

		public function clickHandler(event: MouseEvent) {
			switchMode();
		}

		public function bigWeatherExitHandler(event: MouseEvent) {
			clearBigWeather();
		}

		public function bigWeatherEnterHandler(e: Event) {
			if (bigWeather.y < centerFrameY) {
				bigWeather.y += 40;
			} else if (bigWeather.y > centerFrameY) {
				bigWeather.y = centerFrameY;
			} else {
				bigWeather.gotoAndStop(bigWeather.storedFrame);
				removeEventListener(Event.ENTER_FRAME, bigWeatherEnterHandler);
			}
		}

		public function weatherClickHandler(event: MouseEvent) {

			var targetButton: SimpleButton = event.currentTarget as SimpleButton;
			var target: MovieClip = targetButton.parent as MovieClip;

			while (target.parent != weatherStage) {
				target = target.parent as MovieClip;
			}

			if (weatherClip.indexOf(target) != -1 && !weatherStage.contains(bigWeather)) {

				bigWeather = new bigWeather_MC;

				bigWeather.theDate.text = "";
				bigWeather.high.text = "";
				bigWeather.low.text = "";
				bigWeather.windSpeed.text = "";
				bigWeather.windDirection.text = "";
				bigWeather.humidity.text = "";

				bigWeather.scaleX = bigWeatherScale;
				bigWeather.scaleY = bigWeatherScale;
				bigWeather.x = centerFrameX;
				bigWeather.y = 0 - bigWeather.height / 2;

				bigWeather.exitButton.addEventListener(MouseEvent.CLICK, bigWeatherExitHandler);

				bigWeather.storedFrame = target.currentFrame;

				bigWeather.weather.text = target.weather.text;
				if (!isDisplayMode) {
					bigWeather.theDate.text = target.theDate.text;
					bigWeather.high.text = target.high.text;
					bigWeather.low.text = target.low.text;
					bigWeather.windSpeed.text = "Windspeed: " + target.WindSpeed;
					bigWeather.windDirection.text = "Wind Direction: " + target.WindDirection;
					bigWeather.humidity.text = "Humidity: " + target.Humidity;
				}

				weatherStage.addChild(bigWeather);
				addEventListener(Event.ENTER_FRAME, bigWeatherEnterHandler);
			}
		}

		public function keyboardHandler(event: KeyboardEvent): void {
			var test: int = 3;
			if (event.ctrlKey) {
				if (event.charCode == 109) {
					switchMode();
				} else if (event.charCode == 114) {
					loadXML();
				}
				/*if(event.charCode == 100){
					mySharedObject.clear();
					trace("Data Cleared");
				}*/
			}
			if (event.charCode == 13) {
				readInput();
			}
		}

		public function clearBigWeather() {
			if (weatherStage.contains(bigWeather)) {
				weatherStage.removeChild(bigWeather);
			}
		}

		public function switchMode() {
			clearBigWeather();

			if (isDisplayMode) {
				ReadWeather();
			} else {
				ShowWeather();
			}
		}

		public function refreshClickHandler(event: MouseEvent) {
			loadXML();
		}

		public function processXML(e: Event): void {
			myXML = new XML(e.target.data);

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
				clearBigWeather();
				ReadWeather();
			} else {
				weatherStage.CityLabel.text = "That city name is invalid."
				chosenCity = lastCity;
			}
		}
		
		public function rereadXML(){
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
				clearBigWeather();
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
				trace("weather clip " + j + " - X: " + weatherClip[j].x + ", Y: " + weatherClip[j].y);

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