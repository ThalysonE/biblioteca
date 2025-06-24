package servicos

import (
	"biblioteca/banco"
	"biblioteca/modelos"
	"biblioteca/servicos/sessao"
	"biblioteca/utilidades"
)

type ErroServicoPais int

const (
	ErroServicoPaisNenhum = iota
	ErroServicoPaisInexistente
	ErroServicoPaisExistente
	ErroServicoPaisNomeOuSiglaDuplicado
	ErroServicoPaisSessaoInvalida
	ErroServicoPaisSemPermissao
	ErroServicoPaisNomeInvalido
	ErroServicoPaisSiglaInvalida
)

func PesquisarPais(idDaSessao uint64, loginDoUsuarioPesquisador string, pais modelos.Pais) ([]modelos.Pais, ErroServicoPais) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuarioPesquisador) != sessao.VALIDO {
		return []modelos.Pais{}, ErroServicoPaisSessaoInvalida
	}

	permissaoDoUsuario := sessao.PegarSessaoAtual()[idDaSessao].Permissao

	if permissaoDoUsuario&utilidades.PermissaoPais != utilidades.PermissaoPais {
		return []modelos.Pais{}, ErroServicoPaisSemPermissao
	}

	return banco.BuscarPaises(pais), ErroServicoPaisNenhum
}

func PegarPaisPeloId(idDoPais int) (modelos.Pais, bool) {
	return banco.PegarPaisPeloId(idDoPais)
}

// vai retornar um hashmap tendo como chave o id do pais e como elemento o modelo.Pais
func PegarTodosOsPaises() map[int]modelos.Pais {
	return banco.PegarTodosOsPaises()
}
