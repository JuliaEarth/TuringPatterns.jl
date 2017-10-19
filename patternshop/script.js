import m from './mithril.js';
import d3 from './d3.js';

const p = (...args) => { console.log.apply(console, args); return args[0] }
const mod = (a, b) => (+a % (b = +b) + b) % b

let state = {
    patterns: [
        // {type: 'simple', r: {xsweep: d3.range(1,7).map(n => 2*n)},  R: {xsweep: d3.range(1,7).map(n => 4*n)},   effectsize: 0.01},
        // {type: 'simple', r: {ysweep: d3.range(1,7).map(n => 5*n)},  R: {ysweep: d3.range(1,7).map(n => 10*n)},  effectsize: 0.02},

        { type: 'composite',
          couplings: null,
          patterns: [
            {type: 'simple', r: 2,  R: 4,   effectsize: 0.01},
            {type: 'simple', r: 4,  R: 8,  effectsize: 0.02},

            {type: 'simple', r: 10, R: 20,  effectsize: 0.03},
          ],
        },

        // { type: 'composite',
        //   couplings: null,
        //   patterns: [
            {type: 'simple', r: 20, R: 40,  effectsize: 0.04},
            {type: 'simple', r: 50, R: 100, effectsize: 0.05},
        //   ],
        // },

    ],
    seed: 1,
    dims: 2,
    iters: 100,
    width: 128,
    height: 128,
    gridsize: 6,
 }

p(m.parseQueryString(m.buildQueryString({a:1,b:[2,3]})))




// Fill in all coupling matrices with the identity

state.patterns.forEach(p => p.type == 'composite' && (p.couplings = d3.cross(d3.range(p.patterns.length), d3.range(p.patterns.length), (a,b) => a==b?1:0)))

const blurOnEnter = e => {
    if (e.keyCode == 13) {
        e.target.blur()
    } else {
        e.redraw = false
    }

}

let param = v => {
    if (typeof v === 'object') {
        p(v)
        let letter = Object.keys(v)[0][0]
        let extent = d3.extent(Object.values(v)[0])
        return `${letter} ${extent[0]} – ${extent[1]}`
    } else {
        return v
    }
}
let Header = () => m('.header', m('.row', m('span.cell', 'r'), m('span.cell', 'R'), m('span.cell', 'Effect')))
let Cell = (value, onchange) => {
    return m('input.cell', {class: isNumeric(value) ? 'single' : 'swept', value: param(value), onchange, onkeydown: blurOnEnter}) // [type=number][step=any][min=0]
}

let Row = (r, R, effect, changed) => {
    return m('.row',
        Cell(r, e => { changed('r', e.target.value) }),
        Cell(R, e => { changed('R', e.target.value) }),
        Cell(effect, e => { changed('effectsize', e.target.value) }),
    )
}


function isNumeric(v) {
    return parseFloat(v) == v;
}


let parseValueOrRange = (v) => {
        p("chk", v, parseFloat(v), v==parseFloat(v))

    if (isNumeric(v)) {
        p("numric", v)
        return parseFloat(v)
    }
    let sep
    switch (true) {
        case v.indexOf('-') > -1: sep = '-'; break;
        case v.indexOf('–') > -1: sep = '–'; break;
        default: sep = null
    }
    if (!sep) { return null }
        p("sep", sep, v)
    let [left, right] = v.split(sep).map(s => s.trim())

    let sweep = 'x'
    if (left.startsWith('x')) {
        sweep = 'x'
        left = left.substring(1).trim()
    }
    if (left.startsWith('y')) {
        sweep = 'y'
        left = left.substring(1).trim()
    }
    if (right.startsWith('x')) {
        sweep = 'x'
        right = right.substring(1).trim()
    }
    if (right.startsWith('y')) {
        sweep = 'y'
        right = right.substring(1).trim()
    }


    left  = Number(parseFloat(left))
    right = Number(parseFloat(right))

    if (isNaN(left) || isNaN(right)) { return null }
    let scale = d3.scaleLinear().domain([0, state.gridsize-1]).range([left, right])
    return { [[sweep + 'sweep']]: d3.range(state.gridsize).map(scale) }
}
let PatternRow = (p) => m('.pattern',
    Row(p.r, p.R, p.effectsize, (k, v) => (p[k] = parseValueOrRange(v) || 1)))

// let percent = d3.format('.1')

let CouplingMatrix = (matrix) => {
    let nelems = Math.sqrt(matrix.length)
    return m('.coupling-matrix', {style: `width: ${nelems * 50}px`},
        d3.cross(
            d3.range(nelems),
            d3.range(nelems),
            (a, b) => {
                let index = nelems * a + b
                return MatrixCell(matrix[index], a == b, (e) => {
                    let v = parseValueOrRange(e.target.value)
                    return matrix[index] = v !== null ? v : (a == b ? 1 : 0)
                })
            }
        )
    )
}

let MatrixCell = (() => {
    let colorScale = d3.scaleLinear().domain([0, 1]).range(['#fff', '#EDEDED'])
    return  (value, diagonal, onchange) => m('input.matrix-cell', { // [type=number][step=any][min=0]
        class: isNumeric(value) ? 'single' : 'swept', value: param(value),
        style: { background: colorScale(diagonal ? 1 : 0) },
        onchange,
        onkeydown: blurOnEnter,
    })
}
)()

let CompositePattern = (patterns, matrix) =>
    m('.composite-pattern',
        patterns,
        CouplingMatrix(matrix)
    )


let TableEditor = () =>
    m('.table-editor')

function patternsToRows(p) {
    switch (p.type) {
        case 'simple':
            return PatternRow(p)
        case 'composite':
            return CompositePattern(p.patterns.map(patternsToRows), p.couplings)
        default:
            throw Error(`Invalid pattern: ${JSON.stringify(p)}`)
    }
}

let Table = () => m('.table',
    Header(),
    state.patterns.map(patternsToRows)
)

let Button = (text, onclick, enabled=true) => m('div.button', {
    class: enabled || 'disabled',
    onclick,
}, text)

let Sweep = () => m('.sweep',
    'Sweeping across ',
    m('em', 'Initial Conditions'),
    ' ',
    m('span.x', '(x)')
)

let Sidebar = () => m('div.sidebar',
    Table(),
    // m('.inline',
    //     Button('Edit Patterns'),
    //     Button('Randomize'),
    // ),
    Button('Randomize Patterns'),
    Button('Randomize Initial Conditions'),
    // Sweep(),
    m('.inline',
        Button('1D', () => state.dims = 1, state.dims == 1),
        Button('2D', () => state.dims = 2, state.dims == 2),
    ),
    m('.iterations',
        m('span.label', 'No. of iterations:'),
        m('input.value[type=number][step=1][min=1]', {value: state.iters, onkeydown: blurOnEnter, onchange: e => state.iters = parseFloat(e.target.value) || 1}),
        m('.bg')
    )
)

let params2query = params =>
    `http://127.0.0.1:8002/generate?${escape(JSON.stringify(params))}`

let Canvas = (vnode) => {
    let base = {
        patterns: state.patterns,
        dims:     state.dims,
        iters:    state.iters,
        width:    state.width,
        height:   state.height,
        seed:     state.seed,
    }
    return m('div.canvas',
        d3.cross(d3.range(state.gridsize), d3.range(state.gridsize), (iy, ix) => {
            p(ix, iy)
            let params = Object.assign({ix: ix+1, iy: iy+1}, base)
            let url = params2query(params)
            p('params', params)
            let title = url
            return m('.image-cell', {style: {width: 100*(1/state.gridsize) + '%', height: 100*(1/state.gridsize) + '%'}},
                m('img', {srcset: `${url} 1x`}), // 'latest.png 2x, latest.png 1x'
                m('.shadow'),
                // m('.name', `${ix+1}, ${iy+1}`)
            )
        })
    )
}

class Vis {
    view() {
        return m('div.patternshop',
            Sidebar(),
            Canvas()
        )
    }
}
m.mount(document.body, Vis)
