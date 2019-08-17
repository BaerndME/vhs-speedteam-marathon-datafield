using Toybox.WatchUi;
using Toybox.Graphics;

class MarathonSkatingDatafieldView extends WatchUi.DataField {
    
    hidden var currentSpeed;
    hidden var averageSpeed;
    hidden var heartrate;
    hidden var distance;
    
    hidden var clockTime;
    hidden var marathonTime;
    hidden var trainingTime;
    
    hidden var setting_competitionDistance;
    
    hidden var DEFAULT_TIME = "00:00:00";
    hidden var APP_VERSION = "0.1.1";

    function initialize() {
        DataField.initialize();
        
        currentSpeed = 0.0f;
        averageSpeed = 0.0f;
        heartrate = 0.0f;
        distance = 0.0f;
        
        clockTime = "Uhrzeit";
        marathonTime = "MaraTimer";
        trainingTime = "TrainTime";
        
        setting_competitionDistance = 42195;
        
        loadSettings();
        
        saveSettings();
    }
    
    function onSettingsChanged(){
    	loadSettings();
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {    
        View.setLayout(Rez.Layouts.MainLayout(dc));

        View.findDrawableById("curSpeedLabel").setText("Cur. spd");
        View.findDrawableById("avgSpeedLabel").setText("Avg.");
        View.findDrawableById("heartrateLabel").setText("HR");
        View.findDrawableById("trainingTimeLabel").setText("Time");
        View.findDrawableById("clockLabel").setText("Clock");
        View.findDrawableById("distanceLabel").setText("Dist");
        View.findDrawableById("marathonLabel").setText("Time 42");
        return true;
    }
    
        
    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    
        currentSpeed = computeCurrentSpeed(info);
        averageSpeed = computeAverageSpeed(info);
        heartrate = computeHeartRate(info);
        distance = computeDistance(info);
        
        clockTime = computeClockTime();
        trainingTime = computeTrainingTime(info);
        marathonTime = computeMarathonTime(info);
        
//        System.println("c:"+currentSpeed+" a:"+averageSpeed+" h: "+heartrate+" t: "+clockTime+" d: "+trainingTime);
    }
    
    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
     	View.findDrawableById("Background").setColor(getBackgroundColor());
     
		var curSpeedValue = View.findDrawableById("curSpeedValue");
		curSpeedValue.setText(currentSpeed.format("%.1f"));
		
		var avgSpeedValue = View.findDrawableById("avgSpeedValue");
		avgSpeedValue.setText(averageSpeed.format("%.1f"));
		
		var heartrateValue = View.findDrawableById("heartrateValue");
		heartrateValue.setText(heartrate.format("%02d"));
		
		var trainingTimeValue = View.findDrawableById("trainingTimeValue");
		trainingTimeValue.setText(trainingTime);
		
		var clockValue = View.findDrawableById("clockValue");
		clockValue.setText(clockTime);
		
		var distanceValue = View.findDrawableById("distanceValue");
		distanceValue.setText(distance.format("%02.2f"));
		
		var marathonValue = View.findDrawableById("marathonValue");
		marathonValue.setText(marathonTime);		
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
    
    // functions

    private function loadSettings(){
    	if ( Toybox.Application has :Storage ) {
		    setting_competitionDistance = Application.Properties.getValue("MarathonDistance");
		} else {
		    setting_competitionDistance = Application.getApp().getProperty("MarathonDistance");
		}		    
    	
    	if (setting_competitionDistance < 2){
    		setting_competitionDistance = 42195;
    	}
    }
    
    private function saveSettings(){
//    	if ( Toybox.Application has :Storage ) {
//		    Application.Properties.setValue("AppVersion", APP_VERSION);
//		} else {
//		    Application.getApp().setProperty("AppVersion", APP_VERSION);
//		}
    }
    
    private function computeCurrentSpeed(info) {
	    if(info.currentSpeed != null) {
	    	var speedAsKmh = info.currentSpeed * 3.6; 
            return speedAsKmh;           
        } else {
            return 0.0f;				
        }
    }
    
    private function computeAverageSpeed(info) {
	    if(info.averageSpeed != null) {
	    	var speedAsKmh = info.averageSpeed * 3.6; 
            return speedAsKmh;           
        } else {
            return 0.0f;				
        }
    }
   
    private function computeHeartRate(info) {
	    if(info.currentHeartRate != null) {
	    	return info.currentHeartRate;                 
        } else {
            return 0.0f;				
        }
    }
   
    private function computeDistance(info) {
	    if(info.elapsedDistance != null) {
	    	return (info.elapsedDistance/1000);                 
        } else {
            return 0.0f;				
        }
    }
   
    private function computeClockTime() {
    	var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        return timeString;
    }   
   
    private function computeTrainingTime(info) {
	    if(info.elapsedTime != null) {
	    	var secondsTotal = info.elapsedTime / 1000f;
		
			var seconds = secondsTotal.toLong() % 60;
			var minutes = (secondsTotal.toLong() / 60) % 60;
			var hours   = (secondsTotal.toLong() / 360) % 24;
			
			var timeString =  Lang.format("$1$:$2$:$3$", [hours.format("%02d"), minutes.format("%02d"), seconds.format("%02d")]);
            return timeString;
        } else {
            return DEFAULT_TIME;				
        }
    }
   
    private function computeMarathonTime(info) {
    	if(info.elapsedTime == null){
			return DEFAULT_TIME;			
    	}
    
    	if(info.elapsedDistance == null){
			return DEFAULT_TIME;			
    	}    
    	
    	var elapsedDistance = info.elapsedDistance;
    	
    	if(elapsedDistance < 10){
    		return DEFAULT_TIME;		
    	}
    	var elapsedTimeInSeconds = info.elapsedTime / 1000f;
    	
//    	var elapsedDistance = 12;
//    	var elapsedTimeInSeconds = 180;
	    
    	var marathonFactor = setting_competitionDistance / elapsedDistance; 
    	var secondsTotal = elapsedTimeInSeconds  * marathonFactor;    	    	
	
		var seconds = secondsTotal.toLong() % 60;
		var minutes = (secondsTotal.toLong() / 60) % 60;
		var hours   = (secondsTotal.toLong() / 3600);
		if (hours > 99){
			hours = 99;
		}				 
		
		var timeString =  Lang.format("$1$:$2$:$3$", [hours.format("%02d"), minutes.format("%02d"), seconds.format("%02d")]);
        return timeString;
    }    
}
