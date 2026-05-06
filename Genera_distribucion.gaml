/**
* Name: Genera_distribution
* Author: Diego Orozco
* allows the user to manually adjust the skew and bias parameters until the desired mean and variance are obtained.
* Tags: 
*/


model Genera_distribution

global {
	float minimum 	<- 0.0;
	float maximum 	<- 100.0;
	float dispersion 	<- 1.0;
	float bias 			<- 0.0;
	int samples 		<- 10000;
	float value min: 0.0 max: 100.0;
	float mean_value;
	float stand_dev;
	list<float> generated_data;
	map histo_data;
	bool update 			<- false;
	bool save_data 		<- false;
	list data_to_save;
	
	float PD	<- 1.348;
	float PC	<- 0.9;
	
	
	init {
		generated_data <- [];
		loop times: samples{
			value <- skew_gauss(minimum, maximum, dispersion, bias);
			generated_data <+ value;
		}
		mean_value <- mean(generated_data);
		stand_dev <- standard_deviation(generated_data);
		histo_data <- distribution_of(generated_data, 10, 0, 100);
	}
	
	reflex update_histogram when: update = true{
		generated_data <- [];
		loop times: samples{
			value <- skew_gauss(minimum, maximum, dispersion, bias);
			
			generated_data <+ value;
			if save_data = true{
				save value to: "../results/data_for_distribution_2.csv" format:"csv" rewrite: false;
			}	
		}

		mean_value <- mean(generated_data);
		stand_dev <- standard_deviation(generated_data);
		histo_data <- distribution_of(generated_data, 20, 0, 100);
		data_to_save <- generated_data;
	}
	
}


experiment distribution type: gui{
	parameter "Minimum" var: minimum;
	parameter "Maximum" var: maximum;
	parameter "skew" var: dispersion;
	parameter "Bias" var: bias;
	parameter "Update Histogram" var: update;
	parameter "Save data" var: save_data;
	output{
		display "resultado" refresh: every(1 #s){
			chart "data_histogram" type: histogram{
				datalist(histo_data at "legend") value: (histo_data at "values");
			}
		}
		monitor "mean" value: mean_value;
		monitor "SD" value: stand_dev;
	}
}


