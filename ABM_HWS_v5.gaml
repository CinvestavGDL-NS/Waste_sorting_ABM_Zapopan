model rutas

global {
    shape_file nodes_shape_file <- shape_file("../includes/nodes.shp");
    shape_file roads_shape_file <- shape_file("../includes/roads.shp");
    shape_file households_shape_file <- shape_file("../includes/NE.shp");
    
    float step <- 10 #s;
    geometry shape <- envelope(roads_shape_file);
    graph road_network;
	int total_people 								<- 0;
	
	// ------------------------------- simulation parameters -------------------------------------//
	
	float rel_inzone_prob 					<- 0.0;			// Prob. of a household to have another household as "relative/family" in the same study area.
																					// About double this value is the proportion of households with a relative in the same study area.
																					
	float govmsg_prob						<- 0.5;				// probability of an agent to be exposed to the informational intervention
	bool msg_intervention 				<- false; 			// Variable indicating if persuasion/training msgs are sent to the household population
	bool fin_incentive						<- false;			// presence of finantial incentives
	int	reward_sched						<- 7;				// Reward schedule for incentive intervention, number of days between reward provision
	float reward_prob						<- 1.0;			// Reward provision probability, probability of receiving the reward. 
	bool habit_on								<- false;			// presence of habit model
	bool str_intervention					<- false;
	float str_interv_factor					<- 0.5;				// Structural intervention, like providing colored bins for waste
	bool test_manualbehavior			<- false;			// To test several models by manually setting sorting percentage.
	bool show_clusters					<- false;
	bool global_morans				<- false;
	bool local_morans					<- false;
	bool LISA								<- false;			
	
	
	float total_waste_gen 					<- 0.0;
	float prob_sorting 							<- 0.66;
	float wastegen_trigger 					<- 16 #h;
	float total_waste_collected;
	
	bool save_data <- false;
	
	//------------------------- GLOBAL VARIABLES FOR BEHAVIOR MODEL -----------------------------//
	
	//------------------ latent variables descriptive statistics (from empirical data) ---------------------//
	// all empirical values have been adapted from their original likert scales to a common 0-100 scale for integration.
	
	// Knowledge, values adapted from Waste Sorting skills in (Delgado & Bustos, 2012)
	float know_mean 		<-44.33;
	float know_sd				<- 20.0;
	
	// Attitude, values adapted from Pro-environmental attitude in (Hall-Lopez & Arturo, 2021) 
	float att_mean			<- 62.5;
	float att_sd					<- 15.0;
	
	// Personal moral norms, values adapted from personal environmental responsability in (Huerta, 2021)
	float moral_mean		<- 80.75;
	float moral_sd				<- 24.83;
	
	// Subjective norms, values adapted from environmetal social norms in Chamorro and García-Gallego, 2023)
	float sn_mean			<- 63.3;
	float sn_sd				<- 24.64;
	
	// Perceived behavioral control, for waste management behavior as resported in (hernandes, 2023)
	float pbc_mean		<- 44.25;
	float pbc_sd			<- 11.33;
	
	// Self-efficacy for waste sorting, values adapted from (Delgado and Bustos, 2012)
	float se_mean			<- 70.3;
	float se_sd				<- 20.0;
	
	// Incentive measures, values adapted from practical benefits, social prestige and economic benefits
	// for pro-enviromnetal behavior in (Venegas-Rico et al, 2018)
	float incen_mean	<- 68.0;
	float incen_sd			<- 16.0;
	
	// Intention, values adapted from enviornmental conservation intention in (Delgado & Bustos, 2012)
	float int_mean		<- 70.0;
	float int_sd				<- 23.33;
	
	// Behavior, values adapted from pro-environmental behavior in (Delgado & Bustos, 2012)
	float beh_mean		<- 45.67;
	float beh_sd			<- 16.67;
	
	// Incentives*intention (moderation effect) SD obtained by sampling data from a joint distribution generated from a gaussian copula with a
	// Pearson correlation coefficient of 0.2, 0.2 obtained from (Wang et al, 2019)
	float intxincen_sd	<- 1860.56; 
	
	//---------- latent variables distribution parameters (adjusted to produce empirical statistics -see above- reported in studies) ------------//
	float know_min 			<- 0.0;
	float know_max 			<- 100.0;
	float know_conc 		<- 1.04;
	float know_bias 			<- -0.28;

	float att_min 			<- 0.0;
	float att_max 			<- 100.0;
	float att_conc 			<- 1.43;
	float att_bias 			<- 0.56;
	
	float moral_min 			<- 0.0;
	float moral_max 		<- 100.0;
	float moral_conc 		<- 0.44;
	float moral_bias 			<- 2.5;	
	
	float sn_min 			<- 0.0;
	float sn_max 			<- 100.0;
	float sn_conc 			<- 0.73;
	float sn_bias 			<- 0.75;	
	
	float pbc_min 				<- 0.0;
	float pbc_max 			<- 100.0;
	float pbc_conc 			<- 2.10;
	float pbc_bias 			<- -0.24;	
	
	float se_min 				<- 0.0;
	float se_max 			<- 100.0;
	float se_conc 			<- 0.87;
	float se_bias 			<- 1.10;
	
	float incen_min 			<- 0.0;
	float incen_max 			<- 100.0;
	float incen_conc 		<- 1.23;
	float incen_bias 			<- 0.86;	
	
	float int_min 			<- 0.0;
	float int_max 			<- 100.0;
	float int_conc 			<- 0.70;
	float int_bias 			<- 1.15;	
	
	float beh_min 			<- 0.0;
	float beh_max 			<- 100.0;
	float beh_conc 			<- 1.32;
	float beh_bias 			<- -0.19;	
	
	//----------------------------- model parameters (factor loadings) -----------------------------------//
	
	// Factor loadings and standard errors (latent variable to latent variable). Standard errors obtanied by 
	// dividing factor loading over t-statistic. Unstandardized loadings. Obtained from (Wang et al, 2019)
	float know_to_att_b 			<- 0.177*att_sd/know_sd;
	float know_to_int_b 			<- 0.365*int_sd/know_sd;
	float know_to_pbc_b	 		<- 0.234*pbc_sd/know_sd;
	float knowtoatt_error		<- 0.177/2.11*att_sd/know_sd;
	float knowtoint_error		<- 0.365/2.91*int_sd/know_sd;
	float knowtopbc_error		<- 0.234/2.73*pbc_sd/know_sd; 
	
	float att_to_int_b 				<- 0.201*int_sd/att_sd;
	float pbc_to_int_b 				<- 0.256*int_sd/pbc_sd;
	float sn_to_int_b 				<- 0.271*int_sd/sn_sd;
	float moral_to_int_b 			<- 0.319*int_sd/moral_sd;
	float atttoint_error			<- 0.201/2.20*int_sd/att_sd;
	float pbctoint_error 		<- 0.256/2.81*int_sd/pbc_sd;
	float sntoint_error			<- 0.271/2.01*int_sd/sn_sd;
	float moraltoint_error		<- 0.319/2.78*int_sd/moral_sd;
	
	float int_to_beh_b 				<- 0.296*beh_sd/int_sd;
	float im_to_beh_b				<- 0.189*beh_sd/incen_sd;
	float inttobeh_error		<- 0.296/2.17*beh_sd/int_sd;
	float imtobeh_error		<- 0.189/2.71*beh_sd/incen_sd;
	
	float PD_mean				<-1.0; 			//average value for base difficulty
	
	// moderators (latent variable to latent variable)
	float im_on_int_beh_b 			<- 0.091*beh_sd/intxincen_sd;
	float imonintbeh_error			<- 0.091/2.11*beh_sd/intxincen_sd;
	
	
	// Constant values (intercepts) for regression models (intention and behavior)

	

	
	//----------------------- Trust levels of the population on goverment -------------------------//
	// NOTE: the 0.00875 correction factor was added to acount for the remaining 3.5% of the population that did not respond
	
	float lowest_level_min 				<- 0.0;
	float lowest_level_max				<- 24.99;
	float lowest_level_prob				<- 0.194+0.00875;
	
	float low_level_min 					<- 25.0;
	float low_level_max					<- 49.99;
	float low_level_prob					<- 0.302+0.00875;
	
	float high_level_min 					<- 50.0;
	float high_level_max					<- 74.99;
	float high_level_prob					<- 0.415+0.00875;
	
	float highest_level_min 				<- 75.0;
	float highest_level_max				<- 100.0;
	float highest_level_prob			<- 0.054+0.00875;
	
	//---------------------------- attitude decay weight list -----------------------------//
	// Attitudes decay based on the time that has passed since the persuasive message was received, this list stores the remaining 
	// effect of a persuasion attempt as function of time passed, the values are only calculated once and used by all household agents
	// The decay function is calculated from the results in (Hill et al, 2013) for the 2000 presidential election. This list is generated in the init section
	
	int buffer_size 	<- 30;
	list<float> att_weights <- list_with(buffer_size+1,0);
	float t_d <-  0.872;
	action get_attweights{
		loop i from: 0 to: buffer_size{
			att_weights[i] <-  (i+1)^(-t_d) ;
		}	
	}
	
    init {
        create intersection from: nodes_shape_file;
        
        create road from: roads_shape_file {
            if ((type = "residential" or type ="living_street") and oneway != "yes") {
                // Crear el camino en la dirección opuesta solo si el atributo "type" es "residential"
                
                create road {
                    num_lanes <- myself.num_lanes;
                    shape <- polyline(reverse(myself.shape.points));
                    // write shape.perimeter; // escribe el tamaño de la calle en metros
                    maxspeed <- myself.maxspeed;
                    linked_road <- myself;
                    myself.linked_road <- self;
                    type <- myself.type; // Mantener el mismo atributo "type"
                    oneway <- myself.oneway;
                }
            }
        }
        
		// Create a graph representing the road network, with road lengths as weights
		map edge_weights <- road as_map (each::each.shape.perimeter);
		road_network <- as_driving_graph(road, intersection) with_weights edge_weights;
		
		// Create houses as points
		create household from: households_shape_file{
				total_people <- total_people + self.family_size;
				//write total_people;
				total_waste_gen <- total_waste_gen + self.mixed_waste;
				//write total_waste_gen;
		}
        // create waste collection agents
        create waste_truck number: 1 with: (location: intersection[116].location, waste_type: "mixed");
        
        // Initialize weights for attitude calculation
		do get_attweights;
		
		population <- length(household);
		
		//dummy values for first local moran's I histogram.
		generated_data <- [0.0];
		histo_data <- distribution_of(generated_data, 100, 0, 100);
		//dummy values for first sort frequency histogram.
		sort_frequencies<- [0.0];
		histo_frequencies <- distribution_of(sort_frequencies, 100, 0, 100);
		
		//bool delete_file_ok <-delete_file("../results/time_series.csv");
		
    }
    int population;
    
    float total_know;
    float total_att;
    float total_pbc;
    float total_moral;
    float total_sn;
    float total_int;
    int total_sorted;
    float total_habit;
    
    float avg_know <- 0.0;
    float avg_att <- 0.0;
    float avg_pbc <- 0.0;
    float avg_moral<- 0.0;
    float avg_sn <- 0.0;
    float avg_int <- 0.0;
    float avg_sorted <-0.0;
    float avg_habit <- 0.0;   
    
    float total_PD;
    float avg_PD;
    
    int total_small;
    int total_verysmall;
    
    reflex get_total_participation{
    	total_know		<- 0.0;
    	total_att			<- 0.0;
    	total_pbc		<- 0.0;
    	total_moral	<- 0.0;
    	total_sn			<- 0.0;
    	total_int 			<- 0.0;
    	total_sorted	<- 0;
    	total_habit		<- 0.0;
    	total_PD			<- 0.0;
    	total_small 		<- 0;
    	total_verysmall	<- 0;
    	
    	ask household{
    		total_know  	<- total_know + self.know;
    		total_att  		<- total_att + self.att;
    		total_pbc  		<- total_pbc + self.pbc;
    		total_moral	<- total_moral + self.moral;
    		total_sn			<- total_sn + self.sn;
    		total_sorted   <- total_sorted + self.waste_sorted;
    		total_int  <- total_int + self.intention_limited;
    		total_habit  <- total_habit + self.habit_str;
    		total_PD		<- total_PD + self.PD;
    		if self.house_size = "small"{total_small<- total_small+1;}
    		if self.house_size = "very small"{total_verysmall<- total_verysmall+1;}
    	}
    	
    	avg_know <- total_know/population;
    	avg_att <- total_att/population;
    	avg_pbc <- total_pbc/population;
    	avg_moral <- total_moral/population;
    	avg_sn <- total_sn/population;
    	avg_sorted <- total_sorted/population;
    	avg_int<- total_int/population;
    	avg_habit <- total_habit/population;
    	avg_PD  <- total_PD/population;
    	
    	float participation;
    	
    	
    	if save_data{
    		participation <- avg_sorted*100;
    		save [cycle, avg_know, avg_att, avg_pbc, avg_moral, avg_sn, avg_int, avg_habit, participation] to: "../results/time_series.csv" format: "csv" rewrite: false header: true;
    	}

    	
    	
    }
    
    reflex finish when: cycle =1800{
    	ask host{
    		do die;
    	}
    
    }
    
    reflex set_struct_intervention{
    	
    	if str_intervention = true{
    		ask household{
    			do get_convfactors(str_interv_factor);
    			self.PD <- float(get_PD(PD0, conv_factors));
    		}
    	}
    	else{
    		ask household{
    			do get_convfactors(str_interv_factor);
    			self.PD <- float(get_PD(PD0, conv_factors));
    		}
    	}
    		
    	
    }
	
	float lag1_metric;
	int cycle_steady_state		<- 1000;
	int lag1_duration		<- 100;
	reflex get_lag1 when: cycle >= cycle_steady_state+1000 and cycle < cycle_steady_state + lag1_duration+1000{
		lag1_metric  <- 0.0;
		ask household{
			lag1_metric <- lag1_metric + self.coincidence;
		}
		lag1_metric <- lag1_metric/population;
		//write lag1_metric;
	}
	
	float P_1_given_1;
	float P_1_given_0;
	
	reflex compute_transition_probs when: cycle >= cycle_steady_state+1000 and cycle < cycle_steady_state + lag1_duration +1000{

		int total_11 <- 0;
		int total_10 <- 0;
		int total_01 <- 0;
		int total_00 <- 0;

		ask household {
			total_11 <- total_11 + self.count_11;
			total_10 <- total_10 + self.count_10;
			total_01 <- total_01 + self.count_01;
			total_00 <- total_00 + self.count_00;
		}

		// evitar divisiones por cero
		if (total_11 + total_10 > 0) {
			P_1_given_1 <- total_11 / (total_11 + total_10);
		}

		if (total_01 + total_00 > 0) {
			P_1_given_0 <- total_01 / (total_01 + total_00);
		}
	
		write "P(1|1): " + P_1_given_1;
		write "P(1|0): " + P_1_given_0;
	}
	
	list<float> vals;
	matrix<float> weights;
	
	
	//**************GLOBAL MORAN'S I *****************//
	float moran_I;
	reflex calculate_morans_I when: cycle >=1000 +1000{
		// obtain household's behavior
		vals <- household collect (each.waste_sorted);
		//write vals;
		
		// intialize weight matrix
		weights <- 0.0 as_matrix{length(vals), length(vals)};
			
			ask household{
				ask self.neighbors{
					weights[int(self), int(myself)] <- 1.0;
				}
		}
		
		// Calculate Moran's I
		moran_I <- moran(vals, weights);
		write moran_I;
	}

	float VAR_local_moran;
	map histo_data;
	list<float>generated_data;
	reflex gen_histogram_localmoran when: cycle > 1000+10000{
		generated_data <- [];
		ask household{
			generated_data <+ self.local_moran;
		}
		histo_data <- distribution_of(generated_data, 52, -0.26, 0.26);
		VAR_local_moran <- variance(generated_data);
		if cycle>1000 and cycle <=1400{
			//write(VAR_local_moran);
		}	
	}

	list<float> sort_frequencies;
	map histo_frequencies;

	reflex gen_histogram_frequency{
		sort_frequencies <- [];
		ask household{
			sort_frequencies <+ self.sort_frequency;
		}
		histo_frequencies <- distribution_of(sort_frequencies, 20, 0, 1);
	}
	
	int total_HH;
	int total_LL;
	int total_HL;
	int total_LH;
	
	reflex get_LISA when: cycle > 1000+1000{
		total_HH <- 0;
		total_LL  <- 0;
		total_HL <- 0;
		total_LH <- 0;
		
		ask household{
			switch self.moran_quadrant{
				match "HH"{
					total_HH <- total_HH +1;
				}
				match "LL"{
					total_LL <- total_LL +1;
				}
				match "HL"{
					total_HL <- total_HL +1;
				}
				match "LH"{
					total_LH <- total_LH +1;
				}
			}
		}
		//write("Total HH: " + total_HH);
		//write("Total LL: " + total_LL);
		//write("Total HL: " + total_HL);
		//write("Total LH: " + total_LH);
		
	}


} // END GLOBAL




species road skills: [road_skill] {
    rgb color <- #white;
    string type; // Atributo para almacenar el tipo de carretera, debe venir incluido entre los atributos de 'highway' de cada road dentro del .shp usado en la simulación.
	string oneway; // Atributo para almacenar oneway
	
    aspect base {
        draw shape color: color end_arrow: 1;

    }
}

species intersection skills: [intersection_skill] {
	aspect base{
			draw ("     " + name) color: #brown;
	}
}


///////////////////////////////////////////------------ HOUSEHOLD AGENT --------------////////////////////////////////////////////////////

species household parallel: true{

	int family_size;											// family size, value set at init, determines waste generation rate for the household
	string house_size;										// house size, value set , determines
	
	
	// Waste generation variables
	float inorg_waste 									<- 0 #kg;
	float org_waste 										<- 0 #kg;
	float mixed_waste 								<- 0 #kg;
	float total_waste; 
	float wastegen_counter 						<- 0 #s;
	
	
	// Social interaction model variables
	float house_radius		<- 10 #m;									// radius for household size calculation
	list <household> neighbors;				
	int number_of_neighbors 	<- 6;									// number of household agents considered neighbors if no neighbor is found 
	household relatives 			<- nil;									// stores one of the other households as family/relatives (depending on a given probability) for subjective norms calculation
	
	// agent behavior model factor loadings, they are derived from the general behavior model regression coefficients and standard errors, 
	//each agent has a particular set of values. Factor loadings are unstandardized.
	
	float know_to_att 				<- gauss(know_to_att_b, knowtoatt_error);					// waste sorting knowlegde effect on attitudes
	float know_to_int 				<- gauss(know_to_int_b, knowtoint_error);					// waste sorting knowlegde effect on intention
	float know_to_pbc				<- gauss(know_to_pbc_b, knowtopbc_error);				// waste sorting knowlegde efect on perceived behavioral control 
	float att_to_int					<- gauss(att_to_int_b, atttoint_error);						// attitudes effect on intention
	float pbc_to_int					<- gauss(pbc_to_int_b, pbctoint_error);					// perceivedf behavioral control effect on intention
	float sn_to_int						<- gauss(sn_to_int_b, sntoint_error);							// subjective norms effect on intention
	float moral_to_int				<- gauss(moral_to_int_b, moraltoint_error);					// personal moral norm effect on intention
	float int_to_beh					<- gauss(int_to_beh_b, inttobeh_error);					// intention effect on behavior
	float im_to_beh					<- gauss(im_to_beh_b, imtobeh_error);					// incentive measures effect on behavior
	
	float im_on_int_beh 			<- gauss(im_on_int_beh_b, imonintbeh_error);		// mediator variable modifying intention effect on behavior 
	
	float int_const	;
	float beh_const; 				
	float pers_baseline;	
	
	

	init {
		// Generates number of people living at the agents location (based on statistics on family size for Zapopan)
        family_size <- rnd_choice([1 :: 0.126, 2 :: 0.196, 3 :: 0.198, 4 :: 0.212, 5 :: 0.142, 6 :: 0.126]);
        // Calculates weekend-generated waste (saturday and sunday generation as starting values for simulation on monday)
		do gen_and_sort_waste(family_size, prob_sorting);  // Saturday generation
		do gen_and_sort_waste(family_size, prob_sorting);  // Sunday generation
		
		// Determines household size, 6.5 meters choosen as average distance given the circunstances, 
		// it's not exact, but good enough since it correctly classifies most of the households in the study area
		do get_house_size(house_radius);
		
		// get convenience factors according to environmental variables, (only house size for this study)
		do get_convfactors;
		
		// Sets Perceived difficulty initial value (APPROACH: USE SE AND PBC TO DERIVE PD FOR THE AGENT
		//PD <- PC*se/(pbc - know_to_pbc*know);
		//PD0 <- PD/conv_factors[0];

		
		// sets initial SE (APPROACH: ASSUME PD0 AND CALCULATE SE ACCORDINGLY)
		// Sets Perceived difficulty initial value
		PD <- float(get_PD(PD0, conv_factors));
		se <- max(100*(pbc - know_to_pbc*know)*PD/(100*PC+(pbc - know_to_pbc*know)*PD-(pbc - know_to_pbc*know)),0);
		
		// Sets relatives for the household
		// do set_relative(rel_inzone_prob);
		// Establishes the closest household agents as neighbors
		neighbors	<- household at_distance(30 #m);
		if neighbors = []{
			neighbors	<- household closest_to(self, number_of_neighbors);	
		}	
		
		num_neighbors <- length(neighbors);		
		
		// Sets trust on the goverment
		//do set_trust;
		
		// Initial state of sorting is false
		waste_sorted <- 0;
		
		// Intercepts calculation for regression equations
		pers_baseline 			<- att - know_to_att_b*know;
		int_const					<- intention - know_to_int*know - att_to_int*att 
											- pbc_to_int*pbc - sn_to_int*sn - moral_to_int*moral;
											
		beh_const					<- beh - int_to_beh*intention - im_to_beh*incen 
											- im_on_int_beh*intention*incen; 				
			
		
		
	}

	// This action selects another household agent as a household where relatives (uncles, grandparents, etc) live given a probability and
	// asks that household to set this household as relative
	action set_relative(float relative_prob) {
   		bool get_relatives <- flip(relative_prob);

   		if get_relatives = true and relatives = nil{
      		relatives <- one_of(household where (each.relatives = nil));
      		//write relatives.name;
      		if (relatives != nil) { 								// verifies if another household was selected
         		ask relatives {
            	self.relatives <- myself;
            	//write self.relatives.name;
         		}
      		}
   		}
	}
	
	// This action is used to generate the waste for a household in a given day via a log-normal distribution  
	//  with an expected value of 0.7353 Kg/person/day, equal to the HOUSEHOLD waste generation per capita in zapopan,
	// then determines if the waste is sorted given a probability of sorting.
	action gen_and_sort_waste(int fam_size, float prob_sort){
		//float waste_generated <- gamma_rnd(1.4, 0.525)*fam_size #kg;
		float waste_generated <- lognormal_rnd(-0.56, 0.71)*fam_size #kg;
			// For now, each home has a 50/50 chance of sorting the waste once a day. Only organic and inorganic fractions are considered.
			if flip(prob_sort){
				// For household waste, 39.9% is organic waste (food waste) and 8.7% is gardening waste
				org_waste <- org_waste + 0.48*waste_generated;
				inorg_waste <- inorg_waste + (1-0.48)*waste_generated;
			}
			else{
				mixed_waste <- mixed_waste + waste_generated;
			}
	}
	
	
	// This action determines house size (and therefore, available space) from the number of neighbors at a certain distance from the household agent.
	action get_house_size(float distance){
		list <household> adj_houses;										// list of adjacent houses at a certain distance from the housesold
		
		adj_houses <- self neighbors_at(distance #m); 		
		if length(adj_houses) > 2{
			house_size <- "very small";										// if there are more than 2 neighbors at given distance, it's considered very small,
		}
		else{
			house_size <- "small";
		}
	}
	
		// Generates waste based on probabilities every couple cycles
	//reflex gen_daily_waste{
		//wastegen_counter <- wastegen_counter + step;
		// if a day (16 h or 57600 s) has passed, generates waste 
		//if (wastegen_counter >= wastegen_trigger #h){
			//do gen_and_sort_waste(family_size, prob_sorting);
			//wastegen_counter <-0 #s;
		//}
	//}
	
	
	
	//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx LOCAL MORAN'S I CALCULATION xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
	float z_agent; 
	float z_neighbor;
	float mean_neighbors;
	float local_moran <- 0.0;
	float weight;
	string moran_quadrant;

reflex get_localmoran_I {

    mean_neighbors <- 0.0;

    z_agent <- waste_sorted - avg_sorted;

    weight <- 1.0 / num_neighbors;

    loop neighbor over: neighbors {
        z_neighbor <- neighbor.waste_sorted - avg_sorted;
        mean_neighbors <- mean_neighbors + weight * z_neighbor;
    }

    local_moran <- z_agent * mean_neighbors;
    
    if z_agent > 0 and mean_neighbors > 0 {moran_quadrant <- "HH";}
    else if z_agent < 0 and mean_neighbors < 0 {moran_quadrant <- "LL";}
    else if z_agent > 0 and mean_neighbors < 0 {moran_quadrant <- "HL";}
    else{moran_quadrant <- "LH";}
}
	
	
	
	///xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx///
	/// --------------------------- BEHAVIOR MODEL ------------------------------- ///
   ///xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx///
	float n; 															// multi-purpose variable
	
	// Since the path coefficients in the TPB extended model used are standarized, the beta-value between two latent variables
	// indicates that 1 standard deviation change in the "cause" variable produces a change of beta standard deviations in the "consequence" variable
	// For example if factor loading pcb -> int is 0.22, a change of 1 standard deviation in pcb produces a change of 0.22 standard deviations on int. 
	// As such, de-standarization is made such that the model can correctly compute the value of the dependent variables.


	// -------------------------------- information reception initial state -------------------------------------//
	
	int msg_received						<- 0;																// waste sorting persuasion/training message received?
	int days_since_last_info 				<- 100;																// Days since agent received the information message.
	int days_since_last_sort 				<- 100;																// Days since agent last sorting action.
	

	// ------------------------------------------ KNOWLEDGE -------------------------------------------//
	
	// Waste sorting knowledge is improved by the agent's own behavior (learning by doing) and 
	// goverment waste sorting training information campaings and workshops. From literature, practice both enhances learning and retention.
	// This includes knowlegde about how to sort, about waste's final destination, and about the environmental/health 
	// benefits/problems of sorting/not sorting waste. 
	// Knowledge decay depends on the person, time since last reinforcement and history of action and training information reception.
	

	float know 								<- skew_gauss(know_min, know_max, know_conc, know_bias) min:0.0 max:100.0;	// get agent values from distribution
	float know_baseline				<- know; 
	float know_prev						<- know;
	float know_delta						<- 0.0;
	
	float learnD								<- gauss(0.10, 0.010) min:0.0 max:2.0;
	float learnP								<- gauss(0.10, 0.010) min:0.0 max:2.0;
	float decayD							<- gauss(0.48, 0.04) min: 0.0;
	float decayP							<- gauss(0.48, 0.04) min: 0.0;
	
	int nrD										<- 0 min:0;
	int nrP										<- 0 min: 0;
	float trD									<- 0.0 min:0.0 max:30.0;
	float trP									<- 0.0 min:0.0 max:30.0;
	float knowD							<- know max:100.0;
	float knowP								<- know max:100.0;

	float knowD_delta;
	float knowP_delta;

	// Knowledge can be boosted by information campaings and self-behavior. Knowledge is assumed to increase substantially at the begining
	// for households who dont know much about waste sorting, with knowledge increase slowing as they become more proficient at sorting.
	// According to literature, training information has a positive, yet lower, effect on knowledge acquisition and retention, while hands-on experience 
	// has a bigger effect on both variables. It is assumed that practice si 50% more effective than passive learning for aquiring knowledge and 
	// 100% more effective at enchancing retention
	

	 
	reflex update_know{
		knowD_delta 			<- (100-knowD)*(learnD*msg_received) - (1-msg_received)*decayD/((1+nrD)*(1+trD))*(knowD-know_baseline);
		knowP_delta			    <- (100-knowP)*(learnP*waste_sorted) - (1-waste_sorted)*decayP/((1+nrP)*(1+trP))*(knowP-know_baseline);
		
		trD			<- trD + msg_received - (1-msg_received); 
		trP			<- trP + waste_sorted - (1-waste_sorted);
		
		nrD			<- (nrD + 1)*(1 - msg_received);
		nrP			<- (nrP + 1)*(1 - waste_sorted);
		
		knowD <- knowD + knowD_delta;
		knowP <- knowP + knowP_delta;

		know_prev <- know;
		know 	<- 0.3*knowD + 0.7*knowP;

	} 			// end update_know


	
	
	
	// ------------------------------------------ ATTITUDES ------------------------------------------//
	
	
	// --------------------------------- trust in information source ----------------------------------//
	// The perceived credibility of source is an important factor affecting several aspects of the behavior model. As such, trust
	// is based on empirical data for the objective population. First, every agent is assigned to a particular sector of the population 
	// and then a random value is assigned through a uniform distribution. This value is set in the init section of the agent.
	int trust_level <- rnd_choice(0::lowest_level_prob, 1::low_level_prob, 2::high_level_prob, 3::highest_level_prob);
	float trust_in_source <- rnd(0.0+(trust_level)*0.25, 0.0+(trust_level+1)*0.25) min:0.0 max: 1.0;
	
	
	int history_size 							<- 7*(trust_level+1);	
	list <int> info_history 				<- list_with(history_size, 0);						// List containing the record of messages received over the last n days

	action set_trust{
		trust_level 					<- rnd_choice(0::lowest_level_prob, 1::low_level_prob, 2::high_level_prob, 3::highest_level_prob);
		trust_in_source 			<- rnd(0.0+(trust_level)*0.25, 0.0+(trust_level+1)*0.25);
	}
	
	
	// Attitudes are given by a normal distribution. The value for the mean is given by results from scientific literature exploring 
	// what's the mexican people attitude towards pro-environmental behavior. Behavior can be modified by
	// promotional information about benefits of waste sorting. 
	
	// The proposed model is an adaptation of an information-processing-based model published in [Hunter, 1984], it only considers
	// the persuasion by messages for the attitude dynamics. The effect of the msg on the agent depends on its current attitude,
	// trust in the information source, 

	float att 								<- skew_gauss(att_min, att_max, att_conc, att_bias) min: 0.1 max:100.0;	// get agent values from distribution
	float att_prev 						<- att;					
	float pers_str;
	float total_persuasion						<- 0.0;
	float persuasion				<- 0.0;
	
	float K_AD							<- gauss(4, 0.4) min:0.0 max: 8.0;

	// A circular (ring) buffer will be implemented to reduce computational load for the attitude calculation. Therefore, a modulus operation is needed.
	// Since GAMA does not provide a modulus operation that considers negative numbers, a custom action (function) is implemented.
	action mod_plus (int a, int b){
		int r <- ((a mod b)+ b) mod b;
		return r;
	}
	
	// RING BUFFER IMPLEMENTATION
	list <float> buffer <- list_with(buffer_size+1,0);
	int start_index <- 0;
	
	action insert_record (float value){
		start_index <- int(mod_plus(start_index-1, buffer_size));
		buffer[start_index] <- value;
	}
	
	
	// Attitude is boosted by media campaings and well designed pro-environmental messages [Evironmental attitudes, Clayton, 2012]. 
	// A household agent can be affected by the intervention (message from media/goverment) depending on a given probability,

	// attitude increase is a function of the number o msg received recently, a moderate amount of msg increase att (up to a point) but
	// over-messaging can trigger a negative response according to literature.


		
	reflex update_att{
		
		// ATTITUDE INCREASE
		if msg_received = 1{
			
			// computes effect of the msg on agent
			n <- float(sum(info_history));
			pers_str <- trust_in_source*(1 - n/history_size);
			
			// computes att increase and stores its value in the buffer for decrease calculation
			persuasion <- (pers_str*(100-att))/(1+((50-att)/att)^2);
			do insert_record(persuasion);

		}
		else{
			do insert_record(0.0);
		}
		
		// ATTITUDE DELTA
		// att delta is calculated as the cumulative effect of the current and all previous att increases affected by their respective decay. 
		// To do it, a circular (ring) buffer containing the last 365 records of att increase, and computes the remaining part
		// of each one depending on the time since they happened. This is based on the results presented in (Hill et al, 2013) for the 2000
		// presidential election. From the result of this study it's estimated that, after 105 days, the original increase has decayed to 5% its original value.
		// as such, after a record is more than a 105 days old, its effect on attitude is assumed to be 0.
		
		total_persuasion <- 0.0;
		loop i from: 0 to: buffer_size {
			int idx <- (start_index + i) mod buffer_size;
			total_persuasion <- total_persuasion + att_weights[i] * buffer[idx];
		}
		//if index =0{
			//write buffer;
		//}
		// computes current att, based on dynamic model of persuasion and the effect of knowledge
		att_prev 			<- att;
		att 					<- pers_baseline + total_persuasion + know_to_att*know;
	}
	


	// --------------------------------- PERSONAL MORAL NORMS ----------------------------------//
	// Personal/moral norms are considered an internalization of values. As such, they are robust and have some "resistance" to change.
	// The change in moral normas is slower compared to the change in moral norms. They are also considered "internalized" social norms.
	
	// There are only a few studies that have explored moral norms in environmentalism in México, and in those,  "environmental responsibility",
	// and "moral imperative" present themselves in the higher end of the spectrum. 
	
	// Furthermore, since personal/moral norms change slowly by internalization, the own behavior and the behavior of others are taken into account
	// for the gradual change in personal norms. The model used is adapted from (Gavrilets, 2021). Coefficients adapted from (Tverskoi, 2023). Since
	// authority is the goverment, conformity is affected by trust in the goverment institutions.
	
	// Unlike attitudes or knowledge, 
	
	float moral 					<- skew_gauss(moral_min, moral_max, moral_conc, moral_bias) min: 0.1 max: 100.0 ;	// get agent values from distribution
	float moral_prev 		<- moral;

	int sort_seen;																	// number of neighbors that have been seen sorting their waste
	int num_neighbors;																	// number of neighbors that could be sorting their waste, value set in init
	

	float k_CA1					<- 0.0016*trust_in_source;										// conformity with authority coefficient 1
	float k_CD					<- 0.0016; 
	float k_CP					<- 0.0022;
	
	
	
	
	
	float moral_delta;
	
	// First, the agent sees how many of its neighbors sorted their waste in the previous cycle
	reflex see_peers_beh{
		sort_seen <- 0;
		ask neighbors{
			myself.sort_seen <-  myself.sort_seen + self.waste_sorted;
		}
	}
	
	reflex update_moral{
		moral_prev			<- moral;
		moral_delta 			<- k_CD*(100*waste_sorted - moral_prev) + k_CP*(100*sort_seen/num_neighbors - moral_prev) + 1*k_CA1*(100 - moral_prev);
		moral 						<- moral + moral_delta;
		
	} 	// end update_moral
	
	
	
	// --------------------------------- SUBJECTIVE NORMS ----------------------------------//
	// Similar to personal/moral norms, subjective norms (injunctive and descriptive norms) are computed used the model shown in  
	// (Gavrilets, 2021) and validated by (Tverskoi, 2023). This model is adapted to account for the evidence that people with high 
	// environmental values (high value in the moral norm variable) are less affected by social/subjective norms and the evidence that,
	// in the case of waste sorting, descriptive norm has a substantially bigger impact than injunctive norm. Coefficients are adapted from (Tiverskoi, 2023)
	
	float sn 					<- skew_gauss(sn_min, sn_max, sn_conc, sn_bias) min:0.0 max:100.0;	// get agent values from distribution
	float sn_prev 			<- sn;
	float inj 					<- sn;																				// injunctive norm part
	float inj_prev 			<- inj;
	float desc				<- sn;																				// descriptive norm part
	float desc_prev		<- desc; 
	

	float k_CA2				<- 0.16*trust_in_source;			// conformity with authoriy coefficient 2
	float k_SP 				<- 0.25;											// social projection coefficient
	float k_LO1				<- 0.28;										// learning about others coefficient 1
	
	
	float k_CA3				<- 0.16*trust_in_source;			// conformity with authoriy coefficient 3
	float k_LC				<- 0.17;											// logic constraints coefficient
	float k_LO2				<- 0.41;											// learning about others coefficient 2
	
	
	float inj_delta;
	float desc_delta;
	float sn_delta;
	
	float B_sn;				// Attenuation constant for subjective norms based on the moral level of the agent
	
	float sn_to_int_eff;
    float moral_to_int_eff;
	
	reflex update_sn{
		
		inj_prev 					<- inj;
		desc_prev				<- desc;
		
		inj_delta 					<- k_SP*(moral_prev - inj_prev) + k_LO1*(100*sort_seen/num_neighbors - inj_prev) + 1*k_CA2*(100 - inj_prev);
		desc_delta				<- k_LC*(inj_prev - desc_prev) + k_LO2*(100*sort_seen/num_neighbors - desc_prev) + 1*k_CA3*(100 - desc_prev);
		

		
		inj 							<- inj + inj_delta;
		desc							<- desc + desc_delta;
		
		// Subjective norm change 
		sn_delta 					<- inj_delta/3 + desc_delta*2/3;
		sn_prev 					<- sn;
		sn							<- sn + sn_delta;	
	} // end update_sn
	
	
	
	// ------------------------- PERCEIVED BEHAVIORAL CONTROL (SELF-EFFICACY) --------------------------//
	// Perceived behavioral control is based on perceived controllability and self-efficacy. 
	
	float pbc 									<- skew_gauss(pbc_min, pbc_max, pbc_conc, pbc_bias) min:0.0 max:100.0;	// Self efficacy of the agent from distribution
	float se									 min:0.0 max:100.0;
	float se_increase;
	float se_decrease;
	float se_delta;
	
	float pbc_delta;
	
	float k_me_plus <- 0.4; 
	float k_ve_plus  <- 0.08;
	float k_me_minus <- 0.8; 
	float k_ve_minus  <- 0.16;
	
	float PC 									<- 0.95; 					// Perceived controllability, presumed high as waste sorting at home is almost completely under agent's control					
	float PD0									<- rnd(PD_mean, PD_mean+0.2) min:0.0; 	// Perceived difficulty base value
	list<float>conv_factors 		<- [];					// convenience factors that affect perceived difficulty of waste sorting
	float gamma_pd						<- gauss(0.3, 0.05) min: 0.0 max:1.0;		// Personal effect of perceived difficulty on self-efficacy
	
	float PD;							// Perceived difficulty of the task given all convenience factors, value set in init.
	float se0;							// Computes self-efficacy base value, value set in init
	
 	// Convenience factors for perceived difficulty. In México, according to (Luna Lara, 2003), house space is the most important factor affecting waste sorting
 	// This variable is set in init and can use an intervention factor (like, goverment providing colored trash cans) for reducing perceived difficulty
	action get_convfactors (float intervention_factor<-1.0){
		conv_factors <- [];
		if house_size = "very small"{
			conv_factors 		<+ 1.4;
		}
		if house_size = "small"{
			conv_factors 		<+ 1.2;
		}
		if intervention_factor != 1.0 {
			conv_factors 		<+ intervention_factor;
		}
	}
	
	// Computes effective perceived difficulty 
	action get_PD (float pd, list<float> Conv_factors){
		loop cf over: Conv_factors{
			pd <- pd*cf;
		}
		return pd;
	}									
	
	// updates pbc for furhter calculations, que initial factors of se_increase and se_decrease are present to attenuate change when approaching
	//  the limits of the Self-efficacy variable
	reflex update_pbc{
		se_increase 		<- (100-se)/PD*(k_me_plus*waste_sorted + k_ve_plus*sort_seen/num_neighbors);
		se_decrease 		<- se*(k_me_minus*(1 - waste_sorted) + k_ve_minus*(1 - sort_seen/num_neighbors));
		
		se_delta 				<- se_increase - se_decrease;
		
		
		se							<- se + se_delta;
		pbc						<- PC*100*se/(se + (100-se)*PD) + know_to_pbc*know;
	} // end update_pbc
	
	
	
	// -------------------------------------- INCENTIVES --------------------------------------//
	// incentives behave a little different in this model, instead of updating how much incentives affect agent's behavior by modifying the "value" of the
	// incentive, they are only either present or absent and that affects how the agent behaves. Evidence suggest that people with high environmental
	// awareness (values, attitude, knowledge) are less affected by finantial incentives and more affected by non-financial ones, while in people with low
	// environmental awareness is the opposite. As such, an environmental score is computed for each agent, to moderate the effect of eaxh type of incentive

	float im0 					<- skew_gauss(incen_min, incen_max, incen_conc, incen_bias)*0.5 min:0.0 max:100.0; // base value of effect of incentives on agent, from distribution
	float incen 						<- 0.0;							// effect of incentives on agent behavior
	float incen_prev				<- incen;
	float perc_weight			<- 0.5;							// Weight for the perceptual component
	float contin_weight		<- 1-perc_weight; 	// Weight for the contingent component
	float perceptual				<- trust_in_source;	// perceptual component for the agent, initial value equal to the trust in the goverment
	float contingent				<- 0.0;							// contingent component
	float alpha						<- gauss(0.05,0.01) min: 0.0;			// Rate of change constant for perceptual component
	int reward_received		<- 0;								// 1 if reward is received, 0 otherwhise.

	int day_number 			<- 0;
	int sorted_number		<- 0;
	

	// incentive effect calculation, only given if agent sorted in the previous cycle.
	reflex update_incen {
		incen_prev <- incen;
		if fin_incentive{
			day_number <- day_number +1; 
			if waste_sorted = 1{
				sorted_number <- sorted_number + 1;
			}
			
			incen				<- perc_weight*perceptual*im0;
			
			if day_number = reward_sched and sorted_number > 0{	
				// Reward reception
				reward_received <- rnd_choice(1 :: reward_prob, 0 :: 1 - reward_prob);
				
				// add contingent component
				contingent <- sorted_number/reward_sched*reward_received;
				incen	<- incen + contin_weight*contingent*im0;
				
				// update instrumentality/perceptual component
				perceptual <- perceptual + alpha*(reward_received - perceptual);

				day_number <- 0;
				sorted_number <- 0;
				reward_received <- 0;
				
			}
			
		}
		else{
			incen <- 0.0;
		}
		
	} // end update_incen
	
	
	// -------------------------------------- INTENTION  --------------------------------------//
	// As oposed to the previous constructs, intention and behavior do not have a dynamic model other than the multiple regression.
	// Therefore, the value of these constructs is re-calculated at each cycle. Further, since the regression model is not perfect (R^2 < 1) and 
	// regression variables are not naturally limited to a specific interval unlike in this simulation, the proposed approach consist of the addition
	// of a structured noise that accounts for the unexplained variance in the regression model in conjunction with a sigmoid centered at the mean value
	// that smoothly limits the output of the regression to 0-100 scale, the sigmoid introduces saturation to the model, which is in line with the saturation 
	// observed in interventions for behavioral change. This approach not only allows the simulation for utilization of increasingly better regression
	// models, but also allows to use the value of the behavior variable directly as a probability for action without introducing empirical thresholds.
	
	float intention  <- skew_gauss(int_min, int_max, int_conc, int_bias);
	float intention_noisy;										// intention value taking into account structured noise
	float intention_limited min:0.0 max:100.0;									// intention value after noise addition and sigmoid filtering
	
	float int_noise;												// Structured error for the intention regression model 
	float ks_int					<- 0.04;						// Sigmoid slope constant. The higher the value, the closer to a cut-off value at the mean 
	
	reflex update_int{
		// intention calculation
		
		intention 							<- int_const + know_to_int*know + att_to_int*att + pbc_to_int*pbc + moral_to_int*moral + sn_to_int*sn;
		
		// intention + noise
		//int_noise 							<- gauss(0, int_error_sd);
		//intention_noisy					<- intention + int_noise*0;
		
		// sigmoid application
		intention_limited				<- 100/(1 + exp(-ks_int*(intention - int_mean)));
		
	} // end update_int
	
	// ----------------------------------------------- HABIT -------------------------------------------//
	// To complete the model, habit is considered as the unnacounted force driving behavior along with intention. Habit is given by 
	// habit strenght according to the model developed by Klein et al. 2011 and verified by Zhang et al, 2022. The initial values for the
	// decay and gain coefficients are taken from Zhang et al, 2022. They are then adjusted to follow empirical data
	
	float habit_str					<- 0.0 min:0.0 max:100.0;					// habit strength
	float habit_str_prev		<- habit_str;		// previous habit strength
	float cue_value				<- 1.0;					// Cue value trioggering the habitual response.
	
	//float k_habitgain 			<- gauss(0.015, 0.003);										// habit gain constant
	//float k_habitdecay			<- gauss(0.005, 0.001);										// habit decay constant
	
	float k_habitgain 			<- gauss(0.80, 0.1);										// habit gain constant
	float k_habitdecay			<- gauss(0.037, 0.01);										// habit decay constant
	
	reflex update_habit{
		//habit_str 					<- habit_str_prev + (1 - habit_str_prev)*waste_sorted*cue_value*k_habitgain - habit_str_prev*k_habitdecay;
		habit_str						<- habit_str_prev + k_habitdecay*(k_habitgain*waste_sorted - habit_str_prev);
		habit_str_prev			<- habit_str;
		habit_str						<- habit_str*100;	
	}
	
	
	// -------------------------------------- BEHAVIOR ----------------------------------------//
	int waste_sorted			<- 0;			// initial value, agent hasn't sorted before.
	int waste_sorted_prev	<-0;
	float beh						<- skew_gauss(beh_min, beh_max, beh_conc, beh_bias) min:0.0 max:100.0;
	float beh_noisy;										// intention value taking into account structured noise
	float beh_limited min:0.0 max:100.0;									// intention value after noise addition and sigmoid filtering
	
	float beh_noise;										// Structured error for the intention regression model 

	

	float weight_diff				<- 0.0;
	float beh_slope  <- 0.0;
	float int_cutoff  <- 50.0;	
	
	// habit moderates the intention-behavior relationship and the incentives-behavior relationship, this is because after habit is set, behavior is mostly
	// driven by habit. Evidence shows that the effect of several interventions (such as incentives or others) lasts for a time and then decays.
	// This reflex is set such that after an intervention is retired, behavior will decay to baseline levels after a certain amount of time.
	
	reflex update_beh when: habit_on=false{
		beh 							<- beh_const + int_to_beh*intention_limited + im_to_beh*incen + im_on_int_beh*intention_limited*incen;
		}
	
	
	
	reflex update_behwithhabit when: habit_on=true{

		if intention_limited <= int_cutoff{
			beh_slope <-	habit_str/int_cutoff; 				// PRIMERA IMPLEMENTACIÓN
			beh				<- beh_slope*intention_limited + im_to_beh*incen;
		}
		else{
			beh_slope <-	(100 - habit_str)/(100 - int_cutoff); 				// PRIMERA IMPLEMENTACIÓN
			beh				<- beh_slope*(intention_limited - int_cutoff) + im_to_beh*incen + habit_str;
		}
	}

	
	
	// ------------------------------------- AGENT DECISION MAKING --------------------------------//
	// since the beh_limited falls between 0 and 100, the agent will take action directly as a random choice with probability equal to the value
	// of beh_limited divided by 100.
	int sort_count <- 0;
	float sort_frequency;
	
	reflex decide_action{
		if test_manualbehavior = false{
			waste_sorted <-		rnd_choice([1 :: beh/100, 0 :: 1 - beh/100]);
		}
		else{
			waste_sorted <-		rnd_choice([1 :: prob_sorting, 0 :: 1 - prob_sorting]);
		}
		
		if cycle>1000{
			sort_count <- sort_count + waste_sorted;
			sort_frequency <- sort_count/(cycle-1000);
		}
		
	}
	
	//--------------------------------------- temporal dependency analysis ----------------------------//
	int coincidence <- 0; 
	int count_11 <- 0;
	int count_10 <- 0;
	int count_01 <- 0;
	int count_00 <- 0;
	
	reflex track_transitions when: cycle >= cycle_steady_state-1 and cycle < cycle_steady_state + lag1_duration{
	
		if (cycle > 0) { 
		
			if (waste_sorted_prev = 1 and waste_sorted = 1) {
				count_11 <- count_11 + 1;
			}
			else if (waste_sorted_prev = 1 and waste_sorted = 0) {
				count_10 <- count_10 + 1;
			}
			else if (waste_sorted_prev = 0 and waste_sorted = 1) {
				count_01 <- count_01 + 1;
			}
			else {
				count_00 <- count_00 + 1;
			}
		}
	}
	
	reflex get_beh_change when: cycle >= cycle_steady_state -1 and cycle < cycle_steady_state + lag1_duration{
		try{ coincidence	<- (waste_sorted = waste_sorted_prev) ? 1:0;
			}
		catch{
			coincidence <- 0;
		}
		waste_sorted_prev <- waste_sorted;		
	} 
	
	
	
	/////////////////////////////////////////PREPARATION FOR NEXT CYCLE////////////////////////////////////////
	// ------------------------------------- MESSAGE RECEPTION -------------------------------------//
	reflex receivemsg{
		msg_received 						<- int(flip(govmsg_prob*int(msg_intervention)));
	}

	// ------------------------------------- HISTORY UPDATE -------------------------------------//
	// One of the features of the model is that it can record how many promotional or training messages has been received in certain 
	// number of days. information reception and history is used to calculate the information history factor
	list<int> dummy <-[];
	
	reflex update_info_history{
		////////////////////////////////////////////////////////
		//remove info_history[6] from: info_history;		// this little loop removes the last element of the list because there is
		loop m from:0 to: history_size-2{					    // a problem when using the built-in functions
			dummy <+ info_history[m];						    // to remove the last element from a list
		}																			//
		info_history <- dummy;										//
		dummy<- [];														//
		////////////////////////////////////////////////////////
		if msg_received = 0{
			info_history 					<- [0]+info_history;													// adds a 0 in a new most recent record
			//days_since_last_info 			<- days_since_last_info + 1;				// increases the number of days since last msg
		}
		else{
			info_history                   <- [1]+info_history;													// adds a 1 in a new most recent record
			//days_since_last_info 			<- 1;
		}

		
	}

	// -------------------------------- SORTING HISTORY UPDATE-------------------------------------//
	// In similar fashion as above, a history of recent past behavior must be generated to be used in several dynamic models
	// It uses the same history size as the information history.
	
	
	//reflex update_sort_history{
		////////////////////////////////////////////////////////
		//remove info_history[6] from: info_history;		// this little loop removes the last element of the list because there is
		//loop m from:0 to: history_size-2{						// a problem when using the built-in functions
			//dummy <+ sort_history[m];							// to remove the last element from a list
		//}																			//
		//sort_history <- dummy;										//
		//dummy<- [];														//
		////////////////////////////////////////////////////////
		//if waste_sorted = 0{
			//sort_history[0] 					+<- 0;													// adds a 0 in a new most recent record
			//days_since_last_sort 			<- days_since_last_sort + 1;				// increases the number of days since last sorting
		//}
		//else{
			//sort_history[0] 					+<- 1;													// adds a 1 in a new most recent record
			//days_since_last_sort 			<- 1;
		//}
	//}
	
	aspect base{
		//draw circle(2*sqrt(inorg_waste/3.1416)) color: #blue border: #black;
		//draw circle(2*sqrt(org_waste/3.1416)) color: #green at: {location.x + 1, location.y + 1} border: #black;
		//draw circle(2*sqrt(mixed_waste/3.1416)) color: #orange at: {location.x + 2, location.y + 2} border: #black;
		//if inorg_waste !=0{
			//draw box(2.5,2.5,inorg_waste/5) at: {location.x, location.y} color: #blue;
		//}
		//if org_waste !=0{
			//draw box(2.5,2.5,org_waste/5) at: {location.x, location.y, location.z+inorg_waste/5} color: #green ;
		//}
		//if mixed_waste !=0 {
			//draw box(2.5,2.5,mixed_waste/5) at: {location.x, location.y, location.z+(inorg_waste+org_waste)/5} color: #goldenrod ;
		//}
		//draw  ("     " + name) color: #yellow font: font("Times", 3, #plain);
		//draw house_size font: font("Times", 1, #plain);
		//draw relatives.name font: font("Times", 1, #plain);
		
		// ASPECT BASE
		if waste_sorted = 0{
			draw circle(2.5) at: {location.x, location.y} color: #blue;
		}
		else{
			draw circle(2.5) at: {location.x, location.y} color: #red;
		}
		
		
		
		
		
		//if house_size = "small"{
			//draw circle(2.5) at: {location.x, location.y} color: #red;
		//}
		//else if house_size = "medium"{
			//draw circle(2.5) at: {location.x, location.y} color: #green;
		//}
		//else{
			//draw circle(2.5) at: {location.x, location.y} color: #blue;
		//}
	}
	
	// ASPECT CLUSTERS
	aspect clusters {



    // HH: alto rodeado de altos
    if (moran_quadrant = "HH") {
        draw circle(2.5) at: {location.x, location.y} color: #red;
    }

    // LL: bajo rodeado de bajos
    else if (moran_quadrant = "LL") {
        draw circle(2.5) at: {location.x, location.y} color: #blue;
    }

    // HL: alto rodeado de bajos (outlier)
    else if (moran_quadrant = "HL") {
        draw circle(2.5) at: {location.x, location.y} color: #orange;
    }

    // LH: bajo rodeado de altos (outlier)
    else if (moran_quadrant = "LH") {
        draw circle(2.5) at: {location.x, location.y} color: #cyan;
    }

    // Caso raro: exactamente cero (opcional)
    else {
        draw circle(2.5) at: {location.x, location.y} color: #black;
    }
}
	
	
}


///////////////////////////////////////////------------ WASTE COLLECTOR AGENT --------------////////////////////////////////////////////////////

species waste_truck skills: [driving] {
    rgb color <- rnd_color(255);
    float pickup_range 						<- 25 #m;
    string waste_type;
    list<intersection> dst_nodes		<- [];
    float previous_x;
    float previous_y;
    float waste_truck_load 					<- 0 #kg;
    float max_capacity 						<- 80000 #kg;
    float go_to_discharge_timer 			<- 0 #s;
    float total_waste_truck;
    float total_fuel								<-0.0;
    float load_percent;
    float consumption_rate;
    float fuel_consumed;
	float distance_driven;
	string status 									<- "collecting";
	float base_2_Czone 						<- 9200 #m;
    float Czone_to_TE 							<- 30500 #m;
    float TE_to_base 							<- 27500 #m;
    float cruise_speed 							<- 9.06 #m/#s; // 32.63 Km/h, average speed commuting, average traffic. From observations.
    float total_distance 						<-0.0;
    image_file waste_truck_icon 			<- image_file("../includes/camioncito_icon.png"); 
    
    init {
        vehicle_length <- 6 #m;
        max_speed <- 0.33 #m / #s; // 1.2 Km/h obtained from real-life operation observations
        max_acceleration <- 0.010; //  m/s^2 to match real-life observations
        
        // Extracts ordered nodes to visit from CSV file and creates a list of intersection agents for path computing.
		file rutas <- csv_file("../includes/rutas.csv");
		loop el over: rutas{
			if el != 0{
				add intersection(int(el)) to: dst_nodes;
				}
			}
			
		// Calculates fuel consumption for commuting from truck lote (base) to collection zone
		do consume_fuel(base_2_Czone, 23/3.6);
    }
    
   	// Calculates route based on its current position and a list of intersection agents.
    reflex select_next_path when: current_path = nil{
        do compute_path graph: road_network nodes: dst_nodes;
    }
    
    // When max_capacity is reached, waste_truck stops being available and spends X amount of time discharging the waste, it resumes the route. 
    // It also calculates fuel consumption for transporting the waste to the transfer station (27 Km away)
    reflex go_to_discharge when: (waste_truck_load >= max_capacity or status = "finished") {
		 
		 // if go_to_discharge timer has been completed, it is ready to resume waste collection
		 if go_to_discharge_timer >= 2 #h and waste_truck_load >= max_capacity {
		 	total_waste_truck <- total_waste_truck  + waste_truck_load;
		 	// Calculates fuel consumption for commuting to go_to_discharge site
		 	do consume_fuel(Czone_to_TE, cruise_speed);
		 	do consume_idle_fuel(25.3+30); // parameter is unloading time at ET or landfill in mins
		 	// Resets waste_truck
		 	waste_truck_load <- 0 #kg;
		 	go_to_discharge_timer <- 0.0 #h;
		 	// Calculates fuel consumption for commuting to collection zone
		 	do consume_fuel(Czone_to_TE, cruise_speed);
		 }
		 // if go_to_discharge timer has not been completed, it increases its value by step
		 else if go_to_discharge_timer <= 2 #h and waste_truck_load >= max_capacity{
		 	go_to_discharge_timer <- go_to_discharge_timer + step;
		 	}
		 // otherwhise, it means that route is finished so vehicle goes TE to discharge and then to truck_lot	
		 else if status = "finished"{
		 	do consume_fuel(Czone_to_TE, cruise_speed); // calculates consumption for commuting to TE
		 	write total_fuel;
		 	do consume_idle_fuel(30+25.3); // parameter is unloading time at ET or landfill in mins PLUS idling after waste collection (for rest of the crew)
		 	waste_truck_load <- 0 #kg;
		 	do consume_fuel(TE_to_base, cruise_speed); // calculates consumption for commuting form TE to truck_lot
		 	write total_fuel;
		 	status <- "to lot";
		 }
	}
    
    
    // Drives to the next location unless there is no more room for waste, 
    reflex commute when: (current_path != nil and waste_truck_load < max_capacity and status = "collecting"){
        previous_x <- location.x;
        previous_y <- location.y;
        do drive;
    }

	reflex complete_route when: current_target = last(dst_nodes) {
		status <- "finished";
		location<-intersection[244].location;
		dst_nodes <- [intersection[244]];
		current_path <- nil;
		
	}


	// If waste_truck is close enough a house, picks the waste of the corresponding type and resets waste of the household agent 
	// while increasing the waste_truck load by an equal amount. After that, it adds the waste to the global variable total_waste_collected
	reflex pick_waste{
		
		ask household at_distance(pickup_range){
			if myself.waste_type = "inorganic"{
				myself.waste_truck_load <- myself.waste_truck_load + self.inorg_waste;
				total_waste_collected <- total_waste_collected + self.inorg_waste;
				self.inorg_waste <- 0 #kg;
			}
			else if myself.waste_type = "organic"{
				myself.waste_truck_load <- myself.waste_truck_load + self.org_waste;
				total_waste_collected <- total_waste_collected + self.org_waste;
				self.org_waste <- 0 #kg;
			}
			else if myself.waste_type = "mixed"{
				myself.waste_truck_load <- myself.waste_truck_load + self.mixed_waste;
				total_waste_collected <- total_waste_collected + self.mixed_waste;
				self.mixed_waste <- 0 #kg;
			}
		}
	}
	
	// Calculates fuel consumption depending on the agent state (20 ton max weight waste_truck, euro class N3, max payload 9 ton)
	// Determines load percentage and from that, corrects the calculationfor the consumption rate, then gets the distance driven since last computation.
	reflex get_fuel_use when: (real_speed != 0 and waste_truck_load < max_capacity and status = "collecting"){ 
		distance_driven 	<-	 sqrt((location.x-previous_x)^2+(location.y-previous_y)^2);
		total_distance 		<- 	total_distance + distance_driven;
		do consume_fuel(distance_driven, real_speed);
		//write "Velocidad: " + real_speed + "  Combustible consumido: " + total_fuel + " Distancia recorrida: " + total_distance;
	}

	action consume_fuel(float dista_driven, float veh_speed){ 
		load_percent 			<- 		waste_truck_load/max_capacity*100;
		consumption_rate 	<- 		(1595.1*(3.6*veh_speed)^(-0.4744))*(1 + 0.36*(load_percent-50)/100)/850 #l/#km;
		fuel_consumed 			<- 		consumption_rate*dista_driven/1000;
		total_fuel 					<-		total_fuel + fuel_consumed;
	}
	
	action consume_idle_fuel (float idle_mins){
		fuel_consumed 		<-	3.79*idle_mins/60;  // Jaunich et al, lifecycle process model for municipal solid waste collection 3.79L/h;
		total_fuel 				<-	total_fuel + fuel_consumed;
		write "fuel consumed idling: " + fuel_consumed;
	}
	
    aspect base {
        if waste_truck_load < max_capacity{
         	//draw triangle(20) color: color rotate: heading + 90 border: #black;
        	draw (waste_truck_icon) size:25 rotate: heading;
        	draw box(13, 6, 7) rotate: heading color:#cyan;
        	draw box(18, 7, 5) rotate: heading color:#white;
        	draw circle(pickup_range) color: #yellow wireframe: true;
        	draw string(waste_truck_load with_precision(2)) + string(" Kg") font: font("Times", 3, #plain);
        	draw string(total_fuel with_precision(2)) +  " L diesel" at: {location.x + 10, location.y + 10} font: font("Times", 0.1, #plain);
        }
        else{
        	draw square(5) color: #magenta;
        	draw "vehiculo descargando";
        }

    }
}

///////////////////////////////////////////------------ GOVERMENT AGENT --------------////////////////////////////////////////////////////

// The goverment agent is in charge of communicating information about waste sorting, pro-environmental behaviors and applying policy 
// according to several variables

species goverment{
	
	int training_interval 			<- 15;		// time interval between waste sorting training
	int sort_info_interval 			<- 1; 		// time interval between sorting 
	int envir_prom_interval 		<- 1; 		// time interval between pro-environmental promotions (on media)

	
	
	
}

experiment recolecta type: gui {
	parameter "manual behavior" var: test_manualbehavior ;
	parameter "sorting probability" var: prob_sorting min:0.0 max:1.0 step:0.05;
	parameter "show clusters (local Moran's I" var: show_clusters;
	//parameter "waste generation interval" var: wastegen_trigger min:0.5 max:16.0 step:0.5;
	
	parameter "mensajes activos" var: msg_intervention category: "Model parameters";
	parameter "Probabilidad de recepción" var: govmsg_prob category: "Model parameters";
	parameter "incentivos financieros" var: fin_incentive category: "Model parameters";
	parameter "include habit model" var: habit_on category: "Model parameters";
	parameter "intervencion estructural" var: str_intervention category: "Model parameters";
	parameter "factor de intervencion estructural" var: str_interv_factor category: "Model parameters";
	
	parameter "Guardar datos" var: save_data  category: "Data parameters";
	
	
	output synchronized: true {
		display map type: 2d background: #gray camera: #isometric{
			//species intersection aspect: base;
			species road aspect: base;
			//species waste_truck aspect: base;	
			species household aspect: base;
		}
		
		display map_clusters type: 2d background: #gray camera: #isometric{
			//species intersection aspect: base;
			species road aspect: base;
			//species waste_truck aspect: base;	
			species household aspect: clusters;
		}
		display "charts" {
			chart "Total participation" type: series {
				data "participation percentage" value: total_sorted/length(household) color: #blue;
				data "average normalized intention" value: total_int/(length(household)*100) color: #red;
				data "knowledge" value: total_know/(length(household)*100) color: #green;
				data "attitude" value: total_att/(length(household)*100) color: #brown;
				data "pbc" value: total_pbc/(length(household)*100) color: #black;
				data "moral norms" value: total_moral/(length(household)*100) color: #magenta;
				data "subjective norms" value: total_sn/(length(household)*100) color: #orange;
				data "Habit Strength" value: total_habit/(length(household)*100) color: #mediumaquamarine;
			}	
		}
	}
}