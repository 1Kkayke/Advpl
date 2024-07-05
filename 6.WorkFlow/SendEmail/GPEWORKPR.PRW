#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} WORKPERGP
fonte feito para rodar em schedule, Envia workflow de aviso de termino de experiencia para responsavel do RH
@type function
@version  protheus 23.10
@author Kayke Silva
@since 17/04/2024
@return variant, return_description
/*/
User function WORKPERGP()

    // VARIAVEIS DEFAULT  
    Default cPara             := ""
    Default aAnexos           := {}
    Default lMostraLog        := .F.
    Default lUsaTLS           := .F.
    
    // Privates e locais
    Local lSendOk             := .T. as logical
    Local aArea               := FwGetArea()
    private _aNomeFuncionario := {}  as Array
    private _aDataVencimentos := {}  as Array
    private _aMatriculas      := {}  as Array
    private _aFiliais         := {}  as Array
    
    PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO 'GPE'
        
        ////////////// 45 dias /////////////
        vence45dias()
        
        if !empty(_aNomeFuncionario) .and. !empty(_aDataVencimentos) .and. !empty(_aMatriculas) .and. !empty(_aFiliais)
            oMail             := CRGSendMail():New()
	        oMail:cTo         := GetMv("MV_WORKGPE") // _cEmailResponsavel
	        oMail:cSubject    := "Aviso de termino de experiencia 45 dias"
            oMail:cBody       := GPEWORKPRHTML() //Informe aqui o corpo no e-mail.
	        lSendOk           := oMail:SendMail()
            _aNomeFuncionario := {}
            _aDataVencimentos := {}
            _aMatriculas      := {}
            _aFiliais         := {}
            FwRestArea(aArea)
        endif
        
        ////////////// 90 dias /////////////
        vence90dias()

        If !empty(_aNomeFuncionario) .and. !empty(_aDataVencimentos) .and. !empty(_aMatriculas) .and. !empty(_aFiliais) 
            oMail          := CRGSendMail():New()
	        oMail:cTo      := GetMv("MV_WORKGPE") // _cEmailResponsavel
	        oMail:cSubject := "Aviso de termino de experiencia 90 dias"
            oMail:cBody    := GPEWORKPRHTML() //Informe aqui o corpo no e-mail.
	        lSendOk        := oMail:SendMail()
            FwRestArea(aArea)
        endif

    Reset Environment

Return 

/*/{Protheus.doc} exp45
Função responsavel por buscar funcionarios com 45 dias de experiencia
@type function
@version protheus 23.10
@author Kayke Silva
@since 17/04/2024
@return retorna o nome dos funcionarios que estão perto do periodo do vencimento da experiencia
/*/
static function vence45dias()
    
    Local _dTemexp   := date() + 5 as Data
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""         as character
    Local oStatement := NIL        as Object

    oStatement       := FWPreparedStatement():New()

    cQuery           := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_VCTOEXP FROM "+RetSqlName("SRA")+ " WHERE D_E_L_E_T_ != '*' AND RA_VCTOEXP = ? ORDER BY RA_VCTOEXP DESC"

    //Definindo consulta e parametros
    oStatement:SetQuery(cQuery)

    oStatement:SetString(1,dtos(_dTemexp))

    cFinalQuery      := oStatement:GetFixQuery()

    MPSysOpenQuery(cFinalQuery, @cAlias)

    // Faz um loop em volta dos registros para preencher variavel com as informações
    while !(cAlias)->(EOF())
        if !empty((cAlias)->RA_VCTOEXP) .and. !empty((cAlias)->RA_NOME)
            aadd(_aNomeFuncionario, (cAlias)->RA_NOME)
            aadd(_aDataVencimentos, (cAlias)->RA_VCTOEXP)
            aadd(_aFiliais,(cAlias)->RA_FILIAL)
            aadd(_aMatriculas,(cAlias)->RA_MAT)
        endif
        (cAlias)->(dbSkip())
    enddo

    (cAlias)->(DBCloseArea())

return

/*/{Protheus.doc} exp90
Função responsavel por buscar funcionarios com 90 dias de experiencia
@type function
@version protheus 23.10
@author Kayke Silva
@since 17/04/2024
@return retorna o nome dos funcionarios que estão perto do periodo do vencimento da experiencia
/*/
static function vence90dias()
    
    Local cQuery     := ""         as character
    Local _dTemexp   := date() + 5 as Data
    Local oStatement := NIL        as Object
    Local cAlias     := GetNextAlias()

    oStatement := FWPreparedStatement():New()

    cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_VCTEXP2 FROM "+RetSqlName("SRA")+ " WHERE D_E_L_E_T_ != '*' AND RA_VCTEXP2 = ?  ORDER BY RA_VCTEXP2 DESC"

    //Definindo consulta e parametros
    oStatement:SetQuery(cQuery)

    oStatement:SetString(1,dtos(_dTemexp))

    cFinalQuery := oStatement:GetFixQuery()

    MPSysOpenQuery(cFinalQuery, @cAlias)
    
    // Faz um loop em volta dos registros para preencher variavel com as informações
    while !(cAlias)->(EOF())
        if !empty((cAlias)->RA_VCTEXP2) .and. !empty((cAlias)->RA_NOME) .and. !empty((cAlias)->RA_FILIAL) .and. !empty((cAlias)->RA_MAT)
            aadd(_aFiliais,(cAlias)->RA_FILIAL)
            aadd(_aMatriculas,(cAlias)->RA_MAT)
            aadd(_aNomeFuncionario, (cAlias)->RA_NOME)
            aadd(_aDataVencimentos, (cAlias)->RA_VCTEXP2)
        endif
        (cAlias)->(dbSkip())
    enddo

return

/*/{Protheus.doc} GPEWORKPRHTML
Função responsável por gerar o HTML que será enviado no E-Mail do aviso de termino de experiencia
@author Kayke silva
@since 17/04/2024
@version 1.0
/*/
static function GPEWORKPRHTML()
    local x     := 0  as numeric
    Local cHtml := '' as character

    cHtml := '<html>'+Chr(13)+Chr(10)
    cHtml += '  <head>'+Chr(13)+chr(10)
    // cHtml += '  <style type="text/css">'+Chr(13)+Chr(10)
    cHTML += '  <title>Aviso de Término de Experiência</title>' +Chr(13)+Chr(10)
    CHtml += '      <style>' +Chr(13)+Chr(10)
    CHtml += '           body {' +Chr(13)+Chr(10)
    CHtml += '              font-family: Arial, sans-serif;' +Chr(13)+Chr(10)
    CHtml += '              margin: 0;'+Chr(13)+Chr(10)
    CHtml += '                  padding: 0;'+Chr(13)+Chr(10)
    chtml += '                      background-color: #f4f4f4;'+Chr(13)+Chr(10)
    chtml += '                          border-radius: 10%;'+ Chr(13) + Chr(10)
    CHtml += '                      }' +Chr(13)+Chr(10)
    chtml += '       h2 {'+Chr(13)+Chr(10)
    chtml += '          text-align: center;'+Chr(13)+Chr(10)
    chtml += '              margin-top: 20px;'+Chr(13)+Chr(10)
    chtml += '                  color: #333;'+Chr(13)+Chr(10)
    chtml += '                              }'+Chr(13)+Chr(10)
    chtml += '       table {' +Chr(13)+Chr(10)
    chtml += '               width: 90%;'+Chr(13)+Chr(10)
    chtml += '                  margin: 20px auto;'+Chr(13)+Chr(10)
    chtml += '                      border-collapse: collapse;' + Chr(13)+Chr(10)
    chtml += '                          box-shadow: 9px 9px 9px rgba(0, 0, 0, 0.1);' + Chr(13)+Chr(10)
    chtml += '                                   border-radius: 8px;' + Chr(13)+Chr(10)
    chtml += '                                       overflow: hidden;' + Chr(13)+Chr(10)
    chtml +='                   }  '+Chr(13)+Chr(10)
    chtml +='    th, td {' +Chr(13)+Chr(10)
    chtml +='       padding: 12px 15px;'    +Chr(13)+Chr(10)
    chtml +='         text-align: left;' +Chr(13)+Chr(10)
    chtml +='                border-bottom: 1px solid #ddd;'+Chr(13)+Chr(10)
    chtml += '                  }'+Chr(13)+Chr(10)
    chtml +='    th {'+Chr(13)+Chr(10)
    chtml +='       background-color: #f8f8f8;'+ Chr(13)+Chr(10)
    chtml +='           font-weight: bold;' + Chr(13)+Chr(10)     
    chtml +='               color: #555;' + Chr(13)+Chr(10)
    chtml +='        }' + Chr(13)+Chr(10)
    chtml +='    tr:hover {'+ Chr(13)+Chr(10)
    chtml +='        background-color: #f2f2f2;'+ Chr(13)+Chr(10)
    chtml +='        }' + Chr(13)+Chr(10)
    chtml +='    .break {' + Chr(13)+Chr(10)
    chtml +='       max-width: 150px;' + Chr(13)+Chr(10)
    chtml +='           white-space: nowrap;' + Chr(13)+Chr(10)
    chtml +='               overflow: hidden;' + Chr(13)+Chr(10)
    chtml +='                   text-overflow: ellipsis;' + Chr(13)+Chr(10)
    chtml +='      }' + Chr(13)+Chr(10)
    chtml +='     @media screen and (max-width: 600px) {' + Chr(13)+Chr(10)
    chtml +='           table {' + Chr(13)+Chr(10)
    chtml +='               width: 100%;' + Chr(13)+Chr(10)
    chtml += '      }' + Chr(13)+Chr(10)
    chtml += '          }'     + Chr(13)+Chr(10)
    chtml += ' </style>' + Chr(13)+Chr(10)
    chtml += ' </head>' + Chr(13)+Chr(10)
    chtml += '  <h2>Aviso de Término de Experiência</h2>' + Chr(13)+Chr(10)
    chtml += '      <table>' + Chr(13)+Chr(10)
    chtml += '          <tr>' + Chr(13)+Chr(10)
    chtml += '              <th>Filial</th>'  + Chr(13)+Chr(10)
    chtml += '                  <th>Matricula</th>' + Chr(13)+Chr(10)
    chtml += '                          <th>Nome</th>' + Chr(13)+Chr(10)
    chtml += '                              <th>Data de Término</th>' + Chr(13)+Chr(10)
    chtml += '          </tr>'  + Chr(13)+Chr(10)
    chtml += '      <tr>' + Chr(13)+Chr(10)

    //<!-- linhas de funcionários aqui -->
    for x := 1  to len(_aFiliais)
         chtml += '  <td>'+_aFiliais[x]+'</td>' + Chr(13)+Chr(10)
            chtml += '  <td>'+_aMatriculas[x]+'</td>' + Chr(13)+Chr(10)
                chtml += '  <td class="break">'+_aNomeFuncionario[x]+'</td>' +\ Chr(13)+Chr(10)
                    chtml += '  <td>'+dtoc(stod(_aDataVencimentos[x]))+'</td>' + Chr(13)+Chr(10)
                        if len(_aFiliais) > 1 
                          chtml += ' </tr>' + Chr(13)+Chr(10)
                        endif
    next
    chtml +='  </tr> ' + Chr(13)+Chr(10)
    chtml +='   </table>'+ Chr(13)+Chr(10)
    chtml +='       </body>'+ Chr(13)+Chr(10)
    chtml +='           </html>'+ Chr(13)+Chr(10)

return(chtml)
