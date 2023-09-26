USE CONGRESO
GO

-- VIEW 1
CREATE VIEW VW_EVENTOS AS
SELECT EV.EVEID, EV.EVENOMBRE, EV.EVEFECHA, EV.EVELUGAR, EV.EVECOSTO,
EX.EXPID, EX.EXPNOMBRE, EX.EXPAPELLIDOS, EX.EXPCORREO, EX.EXPCELULAR
FROM EVENTOS EV
INNER JOIN EXPOSITORES EX ON EV.EXPID = EX.EXPID
GO

-- VIEW 2
CREATE VIEW VW_REGISTROS AS
SELECT
    -- REGISTROS
    R.FOLIO, R.FECHA,
    -- CONGRESOS
    C.CONID, C.CONNOMBRE, C.CONDESCRIPCION, C.CONFECHAINI, C.CONFECHAFIN, C.CONLUGAR,
    -- VIEW 3
    E.*
FROM REGISTROS R
INNER JOIN CONGRESOS C ON R.CONID = C.CONID
INNER JOIN ESTUDIANTES E ON R.ESTID = E.ESCID
GO

-- VIEW 3
CREATE VIEW VW_ESTUDIANTES AS
SELECT
    -- ESTUDIANTE
    E.ESTID, E.ESTNOMBRE, E.ESTAPELLIDOS, E.ESTDOMICILIO, E.ESTCORREO, E.ESTCELULAR,
    -- ESCUELA
    S.ESCID, S.ESCNOMBRE, S.ESCDOMICILIO,
    -- MUNICIPIO
    M.MUNID, M.MUNNOMBRE
FROM ESTUDIANTES E
INNER JOIN ESCUELAS S ON E.ESCID = S.ESCID
INNER JOIN MUNICIPIOS M ON S.MUNID = M.MUNID
GO

-- VIEW 4
CREATE VIEW VW_EVENTOXREGISTRO AS
SELECT
    -- VIEW 1
    E.*,
    -- VIEW 2
    R.*
FROM EVENTOXREG ER
INNER JOIN VW_EVENTOS E ON ER.EVEID = E.EVEID
INNER JOIN VW_REGISTROS R ON ER.FOLIO = R.FOLIO
GO

-- SELECTS
SELECT * FROM VW_EVENTOS
SELECT * FROM VW_REGISTROS
SELECT * FROM VW_ESTUDIANTES
SELECT * FROM VW_EVENTOXREGISTRO

-- DROPS
DROP VIEW VW_EVENTOS
DROP VIEW VW_REGISTROS
DROP VIEW VW_ESTUDIANTES
DROP VIEW VW_EVENTOXREGISTRO