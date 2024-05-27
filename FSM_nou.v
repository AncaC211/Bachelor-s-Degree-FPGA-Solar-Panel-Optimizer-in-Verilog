module FSM_nou(

input wire BTN_0,//buton pentru controlul servomecanismului spre stanga
input wire BTN_1,//buton pentru controlul servomecanismului spre dreapta
input wire BTN_2,//buton pentru controlul servomecanismului in sus si pentru initierea calibrarii
input wire BTN_3,//buton pentru controlul servomecanismului in jos si pentru initierea calibrarii
		 // butoanele BTN_2 si BTN_3 se apasa simultan pentru controlul initierii calibrarii

input contor_stanga,//contor pentru traversare orizontala spre stanga
input contor_jos,//contor pentru traversare verticala in jos
input contor_dreapta_sus,//contor pentru detectarea maximului orizontal si vertical
	// acest semnal ar putea combina doua functii: contorizarea pentru pozitia dreapta a servomecanismului
	//orizontal si pozitia superioara a servomecanismului vertical
	//Este utilizat pentru a detecta punctele de maxim tensiune sau pozi?iile limitã în 
	//timpul traversarii ?i calibrarii ambelor servomecanisme.

input wire CLK, //semnal de ceas
output reg t_orizontala, //Semnal de ie?ire pentru traversarea orizontalã, vine de la hor.sweep
output reg t_verticala, //Semnal de ie?ire pentru traversarea verticala, vine de la vertical sweep
output reg maximul_curent, //semnal de iesire pentru masurarea  maximului curent
output reg servo_stanga, //Semnal de ie?ire pentru controlul servomecanismului spre stânga
output reg servo_dreapta, //Semnal de ie?ire pentru controlul servomecanismului spre dreapta
output reg servo_sus, // Semnal de ie?ire pentru controlul servomecanismului în sus
output reg servo_jos, // Semnal de ie?ire pentru controlul servomecanismului în jos
output reg [4:0] stari, //// Starea curentã a FSM, codificatã pe 5 bi?i
output reg reset_contori // semnal de reset pentru contoare
);

//Declare stari

localparam manual=3'b000; //Starea de control manual
localparam traversare_orizontala=3'b001; // Starea de traversare orizontalã
localparam maxim_orizontal=3'b010; //Starea de detectare a maximului orizontal
localparam traversare_verticala=3'b011; // Starea de traversare verticala
localparam maxim_vertical=3'b100; //Starea de detectare a maximului vertical

//Variabile de stare

reg [2:0] starea_curenta;
reg [2:0] starea_urmatoare;


//Actualizarea starii curente la fiecare front de ceas(sincron)

always @(posedge CLK) begin
	starea_curenta<=starea_urmatoare;
end

//Resetare semnale de control ale servomecanismelor(combinational)

always @(*)begin
	//Resetare semnale de control ale servomecanismelor
	servo_stanga=1'b0;
	servo_dreapta=1'b0;
	servo_sus=1'b0;
	servo_jos=1'b0;

	//definirea fiecarei stari

	case(starea_curenta)
	manual: begin
		stari=5'b00001;
		if(BTN_2==1'b1 && BTN_3==1'b1) begin //se initiaza calibrarea
			starea_urmatoare=traversare_orizontala;
			reset_contori=1'b0;// nu resetez contorii
			t_orizontala=1'b1;//activeaza traversarea orizontala
			t_verticala=1'b0;//Dezactiveazã traversarea verticala
			maximul_curent=1'b0; // Dezactiveazã semnalul de maxim
		end else begin

			// Control manual al servomecanismelor pe baza butoanelor

			//control stanga
			if(BTN_0==1'b1) begin
				servo_stanga=1'b1;
				servo_dreapta=1'b0;
			end else begin
				servo_stanga=1'b0;
			end
			//control dreapta
			if(BTN_1==1'b1) begin
				servo_dreapta=1'b1;
				servo_stanga=1'b0;
			end else begin
				servo_dreapta=1'b0;
			end
			//control sus
			if(BTN_2==1'b1) begin
				servo_sus=1'b1;
				servo_jos=1'b0;
			end else begin
				servo_sus=1'b0;
			end

			//control jos
			if(BTN_3==1'b1) begin
				servo_jos=1'b1;
				servo_sus=1'b0;
			end else begin
				servo_jos=1'b0;
			end

			starea_urmatoare=manual;
			reset_contori=1'b1;
			t_orizontala=1'b0;
			t_verticala=1'b0;
			maximul_curent=1'b0;
		end
	end
	traversare_orizontala: begin
		stari=5'b00010;
		reset_contori=1'b0;
		if (contor_stanga == 1'b1) begin
                    servo_stanga = 1'b1; // Activeazã servomecanismul stânga
                    servo_dreapta = 1'b0;
                    t_orizontala = 1'b1;      // Activeazã mãturarea orizontalã
                    t_verticala = 1'b0;      // Dezactiveazã mãturarea verticalã
                    maximul_curent = 1'b0;      // Dezactiveazã semnalul de maxim
                    starea_urmatoare = traversare_orizontala; // Men?ine starea de mãturare orizontalã
                end else begin
                    servo_stanga = 1'b0;
                    servo_dreapta  = 1'b0;
                    starea_urmatoare = maxim_orizontal ; // Trecerea la starea de maxim orizontal
                    t_orizontala = 1'b0;      // Dezactiveazã  mãturarea orizontalã
                    t_verticala = 1'b0;      // Dezactiveazã mãturarea verticalã
                    maximul_curent = 1'b1;
                end
          end


	maxim_orizontal: begin
                stari = 5'b00100; // Starea de detectare a maximului orizontal
                reset_contori = 1'b0; // Nu reseteazã contorul
                if (contor_dreapta_sus == 1'b1) begin
                    servo_dreapta  = 1'b1; // Activeazã servomecanismul dreapta
                    servo_stanga = 1'b0;
                    t_orizontala = 1'b0;      // Dezactiveazã mãturarea orizontalã
                    t_verticala = 1'b0;      // Dezactiveazã mãturarea verticalã
                    maximul_curent = 1'b1;      // Activeazã semnalul de maxim
                    starea_urmatoare = maxim_orizontal; // Men?ine starea de maxim orizontal
                end else begin
                    servo_dreapta  = 1'b0;
                    servo_stanga = 1'b0;
                    starea_urmatoare = traversare_verticala; // Trecerea la starea de mãturare verticalã
                    maximul_curent = 1'b0;       // Dezactiveazã semnalul de maxim
                    t_verticala = 1'b1;       // Activeazã mãturarea verticalã
                    t_orizontala = 1'b0;       // Dezactiveazã mãturarea orizontalã
                end
            end

	traversare_verticala: begin
                stari = 5'b01000; // Starea de mãturare verticalã
                reset_contori = 1'b0; // Nu reseteazã contorul
                if (contor_jos == 1'b1) begin
                    servo_jos = 1'b1; // Activeazã servomecanismul jos
                    servo_sus = 1'b0;
                    starea_urmatoare = traversare_verticala ; // Men?ine starea de mãturare verticalã
                    t_orizontala = 1'b0;       // Dezactiveazã mãturarea orizontalã
                    t_verticala = 1'b1;       // Activeazã mãturarea verticalã
                    maximul_curent = 1'b0;       // Dezactiveazã semnalul de maxim
                end else begin
                    servo_jos = 1'b0;
                    servo_sus = 1'b0;
                    starea_urmatoare = maxim_vertical; // Trecerea la starea de maxim vertical
                    t_orizontala = 1'b0;     // Dezactiveazã mãturarea orizontalã
                    t_verticala = 1'b0;     // Dezactiveazã mãturarea verticalã
                    maximul_curent = 1'b1;     // Activeazã semnalul de maxim
                end
            end
            maxim_vertical: begin
                stari= 5'b10000; // Starea de detectare a maximului vertical
                reset_contori = 1'b0; // Nu reseteazã contorul
                if (contor_dreapta_sus == 1'b1) begin
                    servo_sus = 1'b1; // Activeazã servomecanismul în sus
                    servo_jos = 1'b0;
                    starea_urmatoare = maxim_vertical; // Men?ine starea de maxim vertical
                    t_orizontala = 1'b0;     // Dezactiveazã mãturarea orizontalã
                    t_verticala = 1'b0;     // Dezactiveazã mãturarea verticalã
                    maximul_curent = 1'b1;     // Activeazã semnalul de maxim
                end else begin
                    servo_sus = 1'b0;
                    servo_jos = 1'b0;
                    starea_urmatoare = manual; // Revenire la starea de control manual
                    t_orizontala = 1'b0; // Dezactiveazã mãturarea orizontalã
                    t_verticala = 1'b0; // Dezactiveazã mãturarea verticalã
                    maximul_curent = 1'b0; // Dezactiveazã semnalul de maxim
                end
            end
            default: begin
                starea_urmatoare = manual; // Stare implicitã: control manual
                servo_stanga= 1'b0;
                servo_dreapta= 1'b0;
                servo_sus = 1'b0;
                servo_jos = 1'b0;
                reset_contori = 1'b1; // Reseteazã contorul
                t_orizontala = 1'b0;      // Dezactiveazã mãturarea orizontalã
                t_verticala = 1'b0;      // Dezactiveazã mãturarea verticalã
                maximul_curent = 1'b0;      // Dezactiveazã semnalul de maxim
                stari= 5'b00000; // Stare implicitã a indicatorului de stare
            end 
        endcase
    end
endmodule






