package servicos

import "biblioteca/banco"
import "biblioteca/modelos"
import "time"
import "biblioteca/servicos/sessao"


type ErroServicoDashboard int

const (
	ErroServicoDashboardNenhum = iota
	ErroServicoDashboardSessaoInvalida
)

func PegarDashboard(idDaSessao uint64, loginDoUsuario string) (modelos.Dashboard, ErroServicoDashboard) {
	if sessao.VerificaSeIdDaSessaoEValido(idDaSessao, loginDoUsuario) != sessao.VALIDO {
		return modelos.Dashboard{}, ErroServicoDashboardSessaoInvalida
	}
	dash := banco.PegarDashboard()
	devolucoesAtrasadosSemana := banco.PegarQtdDevolucoesAtrasadoSemana()
	for i := int(time.Now().Weekday()) - 1; i >= 0; i -= 1 {
		dash.QtdLivrosAtrasadosSemana[i] = dash.QtdLivrosAtrasadosSemana[i + 1] + devolucoesAtrasadosSemana[i]
	}
	return dash, ErroServicoDashboardNenhum
}
