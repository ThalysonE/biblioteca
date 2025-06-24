package rotas

import (
	"biblioteca/modelos"
	"biblioteca/servicos"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func erroServicoExemplarParaErroHttp(erro servicos.ErroServicoExemplar, resposta http.ResponseWriter) {
	switch erro {
	case servicos.ErroServicoExemplarLivroInexistente:
		resposta.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(resposta, "Livro não encontrado")
	case servicos.ErroServicoExemplarStatusInvalido:
		fallthrough
	case servicos.ErroServicoExemplarEstadoInvalido:
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "Requisão para a rota de exemplar mau feito")
	case servicos.ErroServicoExemplarMudouLivro:
		resposta.WriteHeader(http.StatusForbidden)
		fmt.Fprintf(resposta, "Não é possível mudar o livro do exemplar")
	case servicos.ErroServicoExemplarExemplarInexistente:
		resposta.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(resposta, "Exemplar não encontrado")
	case servicos.ErroServicoExemplarSemPermissao:
		resposta.WriteHeader(http.StatusForbidden)
		fmt.Fprintf(resposta, "Usuário não tem permissão o suficiente para realizar essa ação")
	case servicos.ErroServicoExemplarSessaoInvalida:
		resposta.WriteHeader(http.StatusUnauthorized)
		fmt.Fprintf(resposta, "Este usuário não está autorizado(logado). Sessão inválida?")
		return
	}
}

type ViewExemplarLivro struct {
	IdDoExemplarLivro int
	Cativo            bool
	Status            int
	Estado            int
	Ativo             bool
	IdDoLivro         int
	Isbn              string
	Titulo            string
	AnoPublicacao     int
	Editora           string
	IdDoPais          int
	NomePais          string
	SiglaPais         string
}

func modelosExemplarLivroParaViewExemplarLivro(exemplares ...modelos.ExemplarLivro) []ViewExemplarLivro {
	views := make([]ViewExemplarLivro, 0, len(exemplares))
	//essa função não deveria poder falhar nesse contexto, por isso ignoramos o erro
	paises := servicos.PegarTodosOsPaises() // creio que isso será mais rápido do que a consulta individual
	for _, exemplar := range exemplares {
		views = append(
			views,
			ViewExemplarLivro{
				IdDoExemplarLivro: exemplar.IdDoExemplarLivro,
				Cativo:            exemplar.Cativo,
				Status:            exemplar.Status,
				Estado:            exemplar.Estado,
				Ativo:             exemplar.Ativo,
				IdDoLivro:         exemplar.Livro.IdDoLivro,
				Isbn:              exemplar.Livro.Isbn,
				Titulo:            exemplar.Livro.Titulo,
				AnoPublicacao:     exemplar.Livro.AnoPublicacao,
				Editora:           exemplar.Livro.Editora,
				IdDoPais:          exemplar.Livro.Pais,
				NomePais:          paises[exemplar.Livro.Pais].Nome,
				SiglaPais:         paises[exemplar.Livro.Pais].Sigla,
			},
		)
	}
	return views
}

type respostaExemplar struct {
	Exemplares []ViewExemplarLivro
}

type requisicaoExemplar struct {
	IdDaSessao        uint64
	LoginDoUsuario    string
	IdDoExemplarLivro int
	IdDoLivro         int
	Cativo            bool
	Status            int
	Estado            int
	Ativo             bool
}

// Nota: Essa função não retorna o modelo com todos os dados
func requisicaoExemplarParaModeloExemplar(requisicao requisicaoExemplar) modelos.ExemplarLivro {
	return modelos.ExemplarLivro {
		IdDoExemplarLivro: requisicao.IdDoExemplarLivro,
		Cativo: requisicao.Cativo,
		Status: requisicao.Status,
		Estado: requisicao.Estado,
		Ativo:  requisicao.Ativo,
		Livro:  modelos.Livro{
			IdDoLivro: requisicao.IdDoLivro,
		},
	}
}

func Exemplar(resposta http.ResponseWriter, requisicao *http.Request) {
	corpoDaRequisicao, erro := io.ReadAll(requisicao.Body)

	if erro != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de exemplar foi mal feita")
		return
	}

	var requisicaoExemplar requisicaoExemplar
	if json.Unmarshal(corpoDaRequisicao, &requisicaoExemplar) != nil {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de exemplar foi mal feita")
		return
	}

	if len(requisicaoExemplar.LoginDoUsuario) == 0 {
		resposta.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(resposta, "A requisição para a rota de exemplar foi mal feita")
		return

	}

	switch requisicao.Method {
	case "POST":
		novoExemplar, erro := servicos.CriarExemplar(
			requisicaoExemplar.IdDaSessao,
			requisicaoExemplar.LoginDoUsuario,
			requisicaoExemplarParaModeloExemplar(requisicaoExemplar),
		)
		if erro != servicos.ErroServicoExemplarNenhum {
			erroServicoExemplarParaErroHttp(erro, resposta)
			return
		}
		respostaExemplar := respostaExemplar{
			Exemplares: modelosExemplarLivroParaViewExemplarLivro(novoExemplar),
		}

		respostaExemplarJson, _ := json.Marshal(&respostaExemplar)
		fmt.Fprintf(resposta, "%s", respostaExemplarJson)
		return
	case "GET":
		exemplaresAchados, erro := servicos.PesquisarExemplares(requisicaoExemplar.IdDaSessao, requisicaoExemplar.LoginDoUsuario, requisicaoExemplarParaModeloExemplar(requisicaoExemplar))
		if erro != servicos.ErroServicoExemplarNenhum {
			erroServicoExemplarParaErroHttp(erro, resposta)
			return

		}
		respostaExemplar := respostaExemplar{
			Exemplares: modelosExemplarLivroParaViewExemplarLivro(exemplaresAchados...),
		}	
		respostaExemplarJson, _ := json.Marshal(&respostaExemplar)
		fmt.Fprintf(resposta, "%s", respostaExemplarJson)
		return
	case "PUT":
		exemplarModificado, erro := servicos.AtualizarExemplar(requisicaoExemplar.IdDaSessao, requisicaoExemplar.LoginDoUsuario, requisicaoExemplarParaModeloExemplar(requisicaoExemplar))

		if erro != servicos.ErroServicoExemplarNenhum {
			erroServicoExemplarParaErroHttp(erro, resposta)
			return
		}

		respostaExemplar := respostaExemplar{
			Exemplares: modelosExemplarLivroParaViewExemplarLivro(exemplarModificado),
		}	
		respostaExemplarJson, _ := json.Marshal(&respostaExemplar)
		fmt.Fprintf(resposta, "%s", respostaExemplarJson)
		return

	case "DELETE":
		exemplarExcluido, erro := servicos.DeletarExemplar(requisicaoExemplar.IdDaSessao, requisicaoExemplar.LoginDoUsuario, requisicaoExemplar.IdDoExemplarLivro)

		if erro != servicos.ErroServicoExemplarNenhum {
			erroServicoExemplarParaErroHttp(erro, resposta)
			return
		}

		respostaExemplar := respostaExemplar{
			Exemplares: modelosExemplarLivroParaViewExemplarLivro(exemplarExcluido),
		}	
		respostaExemplarJson, _ := json.Marshal(&respostaExemplar)
		fmt.Fprintf(resposta, "%s", respostaExemplarJson)
		return

	}

	

}
