package modelos

const (
	DOMINGO = iota
	SEGUNDA
	TERCA
	QUARTA
	QUINTA
	SEXTA
	SABADO
)

type Dashboard struct {
	QtdEmprestimoSemana      [7]int
	QtdDevolucaoSemana       [7]int
	QtdLivrosAtrasadosSemana [7]int
}
