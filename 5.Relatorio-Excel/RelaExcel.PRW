#INCLUDE 'TOTVS.CH'
#Include "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"

//Constantes
#Define STR_PULA Chr(13)+Chr(10)

/*/{Protheus.doc} RelExcel
Como vai ser gerado o exel
@type function
@version 12.1.33
@author Kayke
@since 26/05/2023
@return variant,
/*/
User Function RelExcel()

	Local aArea    := GetArea()
	Local cArquivo := GetTempPath()+ 'zTstExc1.xml'
	Local cQuery   := ""
	Local oExcel
	Local oFWMsExcel

	//Pegando os dados
	cQuery := " SELECT "                                        + STR_PULA
	cQuery += "     A1_COD, "                                 	+ STR_PULA
	cQuery += "     A1_NOME, "                                	+ STR_PULA
	cQuery += "     A1_LOJA, "                                	+ STR_PULA
	cQuery += "     A1_ESTADO, "                                + STR_PULA
	cQuery += "  A1_TIPO, "   									+ STR_PULA
	cQuery += "     A1_MUN, "                               	+ STR_PULA
	cQuery += "     A1_END "                                	+ STR_PULA
	cQuery += " FROM "                                          + STR_PULA
	cQuery += "     " + RetSQLName('SA1') + " SA1 "             + STR_PULA
	cQuery += " WHERE "                                         + STR_PULA
	cQuery += "    A1_FILIAL = '" + FWxFilial('SA1') + "' "     + STR_PULA
	cQuery += "     AND D_E_L_E_T_ = ' ' "                      + STR_PULA
	cQuery += " ORDER BY "                                      + STR_PULA
	cQuery += "     A1_FILIAL "                                 + STR_PULA
	TCQuery cQuery New Alias "QRYPRO"

	oFWMsExcel	:= FWMSExcel():New()

	oFWMsExcel:AddworkSheet("Tabela de testes")

	oFWMsExcel:AddTable("Tabela de testes","Clientes")

	// Adicionando colunas e fazendo a relção com o objeto
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Codigo",1,,.t.)
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Nome",1,,.t.)
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Loja",1,,.t.)
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Tipo ",1,,.t.)
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Estado",1,,.t.)
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Municipio ",1,,.t.)
	oFWMsExcel:AddColumn( "Tabela de testes","Clientes","Endereço",1,,.t.)

	//Criando as Linhas... Enquanto não for fim da query
	While !(QRYPRO->(EoF()))
		oFWMsExcel:AddRow("Tabela de testes","Clientes",{;
			QRYPRO->A1_COD,;
			QRYPRO->A1_NOME,;
			QRYPRO->A1_LOJA,;
			QRYPRO->A1_TIPO,;
			QRYPRO->A1_ESTADO,;
			QRYPRO->A1_MUN,;
			QRYPRO->A1_END;
			})

		//Pulando Registro
		QRYPRO->(DbSkip())
	EndDo

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New() //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo) //Abre uma planilha
	oExcel:SetVisible(.T.) //Visualiza a planilha

	QRYPRO->(DbCloseArea())
	RestArea(aArea)
Return
