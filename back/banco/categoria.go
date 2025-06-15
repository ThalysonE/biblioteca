package banco

import (
	"biblioteca/modelos"
	"context"
	"strings"

	pgx "github.com/jackc/pgx/v5"
)

type ErroBancoCategoria int

const (
	CategoriaErroNenhum = iota
	ErroCategoriaDescricaoDuplicada
	ErroCategoriaInexistente
	ErroCategoriaExecutarCriacao
	ErroCategoriaExecutarAtualizacao
	ErroCategoriaExecutarExclusao
)

func PesquisarCategoria(busca string) []modelos.Categoria {
	conexao := PegarConexao()
	busca = "%" + strings.ToLower(busca) + "%"
	textoQuery := "SELECT id_categoria, descricao, ativo FROM categoria WHERE trim(lower(id_categoria::varchar)) LIKE $1 OR trim(lower(descricao)) LIKE $1"

	linhas, erro := conexao.Query(context.Background(), textoQuery, busca)
	if erro != nil {
		return []modelos.Categoria{}
	}
	var categoriaTemporaria modelos.Categoria
	categoriasEncontradas := make([]modelos.Categoria, 0)
	_, erro = pgx.ForEachRow(linhas, []any{&categoriaTemporaria.IdDaCategoria, &categoriaTemporaria.Descricao, &categoriaTemporaria.Ativo}, func() error {
		categoriasEncontradas = append(categoriasEncontradas, categoriaTemporaria)
		return nil
	})
	if erro != nil {
		return []modelos.Categoria{}
	}
	return categoriasEncontradas
}

func PegarTodasCategorias() []modelos.Categoria {
	conexao := PegarConexao()
	textoQuery := "SELECT id_categoria, descricao, ativo FROM categoria"
	linhas, erro := conexao.Query(context.Background(), textoQuery)
	if erro != nil {
		return []modelos.Categoria{}
	}

	var categoriaTemporaria modelos.Categoria
	categoriasEncontradas := make([]modelos.Categoria, 0)
	_, erro = pgx.ForEachRow(linhas, []any{&categoriaTemporaria.IdDaCategoria, &categoriaTemporaria.Descricao, &categoriaTemporaria.Ativo}, func() error {
		categoriasEncontradas = append(categoriasEncontradas, categoriaTemporaria)
		return nil
	})
	if erro != nil {
		return []modelos.Categoria{}
	}
	return categoriasEncontradas
}

func CriarCategoria(novaCategoria modelos.Categoria) ErroBancoCategoria {
	conexao := PegarConexao()

	_, erroQuery := conexao.Exec(context.Background(),
		"INSERT INTO categoria (descricao, data_criacao) VALUES ($1, current_timestamp)", novaCategoria.Descricao,
	)

	if erroQuery != nil {
		return ErroCategoriaExecutarCriacao
	}
	return CategoriaErroNenhum
}

func PegarCategoriaPeloId(id uint64) (modelos.Categoria, bool) {
	conexao := PegarConexao()
	var categoria modelos.Categoria
	textoQuery := "SELECT id_categoria, descricao, ativo FROM categoria WHERE id_categoria = $1"

	if erro := conexao.QueryRow(context.Background(), textoQuery, id).Scan(
		&categoria.IdDaCategoria,
		&categoria.Descricao,
		&categoria.Ativo,
	); erro == nil {
		return categoria, true
	} else {
		return categoria, false
	}
}

func AtualizarCategoria(CategoriaAtualizada modelos.Categoria) ErroBancoCategoria {
	conexao := PegarConexao()

	textoQuery := "UPDATE categoria SET descricao = $1, data_atualizacao = current_timestamp WHERE id_categoria = $2"
	if _, erroQuery := conexao.Exec(
		context.Background(), textoQuery, CategoriaAtualizada.Descricao, CategoriaAtualizada.IdDaCategoria,
	); erroQuery != nil {
		return ErroCategoriaExecutarAtualizacao
	}

	return ErroNenhum
}

func ExcluirCategoria(IdDaCategoria uint64) ErroBancoCategoria {
	conexao := PegarConexao()

	if _, erroQuery := conexao.Exec(
		context.Background(),
		"update categoria set ativo = false WHERE id_categoria = $1", IdDaCategoria,
	); erroQuery != nil {
		return ErroCategoriaExecutarExclusao
	}

	return ErroNenhum
}

func PegarIdCategoria(descricao string) uint64 {
	conexao := PegarConexao()
	var id uint64
	if conexao.QueryRow(context.Background(), "SELECT id_categoria FROM categoria WHERE descricao = $1", descricao).Scan(&id) == nil {
		return id
	} else {
		return 0
	}
}
