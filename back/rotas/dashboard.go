package rotas

import (
	"biblioteca/servicos"
	"encoding/json"
	"fmt"
	"net/http"
	"io"
)


type RequisicaoDashboard struct {
	IdDaSessao               uint64 `validate:"required"`
	LoginDoUsuarioRequerente string `validate:"required"`
}

func Dashboard(resposta http.ResponseWriter, requisicao *http.Request) {
	if requisicao.Method != "GET" {
		resposta.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	corpoDaRequisicao, erro := io.ReadAll(requisicao.Body)

	if erro != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de categoria foi mal feita")
		return
	}


	var requisicaoDashboard RequisicaoDashboard
	if json.Unmarshal(corpoDaRequisicao, &requisicaoDashboard) != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de categoria foi mal feita")
		return
	}

	dash, erro_dash := servicos.PegarDashboard(requisicaoDashboard.IdDaSessao, requisicaoDashboard.LoginDoUsuarioRequerente)

	if erro_dash != servicos.ErroServicoDashboardNenhum {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "Sessão inválida")
		return
	}

	dashJson, _ := json.Marshal(dash)

	fmt.Fprintf(resposta, "%s", dashJson)
}
