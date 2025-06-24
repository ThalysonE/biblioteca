package modelos

type Livro struct {
	IdDoLivro     int
	Isbn          string
	Titulo        string
	AnoPublicacao int
	Editora       string
	Pais          int
}

type LivroResposta struct {
	IdDoLivro     int
	Isbn          string
	Titulo        string
	AnoPublicacao int
	Editora       string
	Pais          Pais
	Autores       []AutorResposta
	Categorias    []Categoria
}
