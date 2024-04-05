#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} RELCOMP01
    @return  Função de pergunta para caso o usuario deseja gerar relatorio de pedido de compras 
    @author  Kayke Laurindo
    @since   28-03-2024
/*/

user function RELCOMP01()

    Local oReport := Nil as Object
    local cAlias := getNextAlias() as Character
    Local cPergRel := "teste"

    oReport := xPrintRel(cAlias,cPergRel)
    oReport:PrintDialog()

Return

/*/{Protheus.doc} xPrintRel
    Imprimir Relatório

    @author  Nome
    @example Exemplos
    @param   [Nome_do_Parametro],Tipo_do_Parametro,Descricao_do_Parametro
    @return  Especifica_o_retorno
    @table   Tabelas
    @since   01-04-2024
/*/
Static Function xPrintRel(cAlias,cPerg)

    local oReport
    local oSection1

    oReport   := TReport():New(cPerg,'title',cPerg,{|oReport|ReportPrint(oReport,cAlias)},'')
    oReport:SetLandScape()
    oReport:SetTotalInLine(.F.)

    oSection1 := TRSection():New(oReport)
    oSection1:SetTotalInLine(.F.)

Return oReport


/*/{Protheus.doc} ReportPrint
    Montar query e abrir em tabela temporária

    @author  Nome
    @example Exemplos
    @param   [Nome_do_Parametro],Tipo_do_Parametro,Descricao_do_Parametro
    @return  Especifica_o_retorno
    @table   Tabelas
    @since   01-04-2024
/*/
static function ReportPrint(oReport, cAlias,cOrdem)
    local oSection1b := oReport:Section(1)

    oSection1b:BeginQuery()
    BeginSQL Alias cAlias
        %noparser%
        SELECT DISTINCT 
            SC7.C7_FILIAL FILIAL,
            SC7.C7_TIPO TIPO,
            SC7.C7_ITEM ITEM,
            SC7.C7_PRODUTO PRODUTO,
            SC7.C7_UM UNIDADE,
            SC7.C7_QUANT QUANTIDADE,
            SC7.C7_PRECO PRC_UNITARIO,
            SC7.C7_TOTAL PRC_TOTAL,
            SC7.C7_DATPRF DT_ENTREGA,
            SC7.C7_LOCAL ARMAZEM,
            SC7.C7_FORNECE FORNECEDOR,
            SC7.C7_CC CENTRO_CUSTO,
            SC7.C7_EMISSAO EMISSAO
            FROM %TABLE:SC7% SC7
    EndSql
    oSection1b:EndQuery()

    oReport:SetMeter((cAlias)->(RecCount()))

    oSection1b:Print()
Return
return Nil
