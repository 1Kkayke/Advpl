#INCLUDE 'totvs.ch'
//definindo user function e a criação da tela

/*/{Protheus.doc} calc
 Calculadora feita em ADVPL
@type function
@version  1.0
@author Kayke Laurindo
@since 30/06/2023
@return variant, return_description
/*/
user function calc()

	oMsDialog := MSDialog():New(110, 110, 450, 343, 'Calculadora', , , , , CLR_WHITE, CLR_BLACK, , , .T.)
	Private cResultado := ""
	Private cValor1    := ""
	Private cValor2    := ""
	Private cTipo      := ""

	oText := TGet():New( 01,01,{|u| If(PCount() > 0 ,cResultado:= u,cResultado)},oMsDialog,146,29,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cResultado,,,, )

	//botoes com numeros definidos de acordo com o tamanho da tela (oMsDialog)
	oTButton0 := TButton():New( 060, 058, "0",oMsDialog,{||numero0("0")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton1 := TButton():New( 060, 030, "1",oMsDialog,{||numero1("1")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 060, 001, "2",oMsDialog,{||numero2("2")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 088, 058, "3",oMsDialog,{||numero3("3")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton4 := TButton():New( 088, 030, "4",oMsDialog,{||numero4("4")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton5 := TButton():New( 088, 001, "5",oMsDialog,{||numero5("5")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton6 := TButton():New( 113, 058, "6",oMsDialog,{||numero6("6")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton7 := TButton():New( 113, 030, "7",oMsDialog,{||numero7("7")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton8 := TButton():New( 113, 001, "8",oMsDialog,{||numero8("8")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton9 := TButton():New( 142, 030, "9",oMsDialog,{||numero9("9")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//botoes com operadores(+,-,*,%,/) aplicados de acordo com tamanho da tela(oMsDialog)
	oTButton10 := TButton():New( 088, 085, "-",oMsDialog,{||operador("-")}, 33,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton11 := TButton():New( 060, 085, "*",oMsDialog,{||operador("*")}, 33,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton12 := TButton():New( 113, 085, "+",oMsDialog,{||operador("+")}, 33,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton13 := TButton():New( 142, 058, "=",oMsDialog,{||igual("=")}, 60,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton16 := TButton():New( 031, 001, "%",oMsDialog,{||operador("%")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton18 := TButton():New( 031, 30, "CE",oMsDialog,{||apagar("CE")}, 100,30,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton20 := TButton():New( 142, 001, "/",oMsDialog,{||operador("/")}, 30,30,,,.F.,.T.,.F.,,.F.,,,.F. )

	oMsDialog:Activate()

return

Static function numero0(cNumero) 
	cResultado := cNumero 
	oText:Refresh() 
return

Static function numero1(cNumero)
	cResultado += cNumero
	oText:Refresh()
return

Static function numero2(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero3(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero4(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero5(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero6(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero7(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero8(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

Static function numero9(cNumero)
	cResultado := cNumero
	oText:Refresh()
return

	//definindo a função dos operadores e definindo o Valor1
Static function operador(cNumero)
	cValor1    := cResultado
	cTipo      := cNumero
	cResultado := ""
	oText:refresh()
Return
	
	//definindo a função do do valor2 e como o calculo sera feito
Static function igual(cNumero)
	cValor2    := cResultado
	cResultado := ""
	U_final()
Return

/*/{Protheus.doc} final
Retorna o calculo final 
@type User function
@version  1.0
@author Kayke
@since 04/07/2024
@return variant, return_description
/*/
user function final()
	if cTipo == "/" .And. cValor2 == "0"
		cResultado := "Não foi possivel realizar o calculo"
		oText:refresh()
	Else
		cResultado := MathC(cValor1,cTipo,cValor2)
		oText:refresh()
	EndIf
RETURN

Static function apagar(cNumero)
	cValor1    := ""
	cValor2    := ""
	cTipo      := ""
	cResultado := ""
	oText:refresh()
Return
