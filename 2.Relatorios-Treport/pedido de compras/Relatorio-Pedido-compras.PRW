#INCLUDE 'TOTVS.CH'
#INCLUDE 'topconn.ch'
/*/{Protheus.doc} RELCOMP01
    @return  Função de pergunta para caso o usuario deseja gerar relatorio de pedido de compras 
    @author  Kayke Laurindo
    @since   28-03-2024
/*/

user function RELCOMP01()

    Local oReport   := Nil                      as Object
    local cAlias    := getNextAlias()           as Character
    Local cPergRel  := "RELATORIO PED. COMPRAS" as Character

    oReport := xPrintRel(cAlias,cPergRel)
    oReport:PrintDialog()

Return

/*/{Protheus.doc} xPrintRel
    Imprimir Relatório
    @author  Kayke Laurindo
    @since   01-04-2024
/*/
Static Function xPrintRel(cAlias,cPerg)

    local oReport   := Nil as Object
    local oSection1 := Nil as Object

    oReport := TReport():New(cPerg,'title',cPerg,{|oReport|ReportPrint(oReport,cAlias)},'')
    oReport:SetLandScape()
    oReport:SetTotalInLine(.F.)

    oSection1 := TRSection():New(oReport)
    oSection1:SetTotalInLine(.F.)

Return oReport

/*/{Protheus.doc} ReportPrint
    Montar query e abrir em tabela temporária
    @author  Kayke Laurindo
    @since   01-04-2024
/*/
Static Function ReportPrint(oReport, cAlias,cOrdem)

	Local cQuery := ""

	cQuery += " SELECT " + CRLF
	cQuery += "     SC7.C7_FILIAL " + CRLF
	cQuery += "    ,SC7.C7_TIPO   " + CRLF
	cQuery += "    ,SC7.C7_ITEM   " + CRLF
	cQuery += "    ,SC7.C7_PRODUTO" + CRLF
	cQuery += "    ,SC7.C7_UM     " + CRLF
	cQuery += "    ,SC7.C7_CODTAB " + CRLF
	cQuery += "    ,SC7.C7_QUANT  " + CRLF
	cQuery += "    ,SC7.C7_PRECO  " + CRLF
	cQuery += "    ,SC7.C7_TOTAL  " + CRLF
	cQuery += "  FROM " + RetSqlName("SC7") + " SC7 "
	cQuery := ChangeQuery(cQuery)
	
	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbCloseArea())
	EndIF
	
	TcQuery cQuery New Alias "QRY"
	
	oSecCab:BeginQuery()
	oSecCab:EndQuery({{"QRY"},cQuery})
	oSecCab:Print()
Return
