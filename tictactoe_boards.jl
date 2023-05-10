### A Pluto.jl notebook ###
# v0.19.25

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ cde42e11-533c-46c3-93b2-0faa1fe98d2d
begin
	using PlutoUI, Random, HypertextLiteral
	TableOfContents()
end

# ╔═╡ 78f67226-07de-40a7-85ac-125eb3d207d7
md"""
# Package Dependencies
"""

# ╔═╡ 9ce498a3-2e64-4e45-bea0-da73b15fa714
md"""
# Game Board Demonstrations
"""

# ╔═╡ 470620fe-e698-41a6-9d86-e8c3cd4abb02
md"""
## Board with reactive style
"""

# ╔═╡ 5cb21f86-fc56-42d4-94c9-a4fb8a60eb58
md"""
# Render Fixed Boards with Style
Alternatively the `make_ttt_board_raw` function can be used to display moves on a board with optional color styling.  The board vector passed to the function should follow the same convention above of using 0, 1, and 2 for the cell states.  This function returns the appropriate HTML as a string and the board id for future styling.  The string must be passed to the `HTML` function to render it.
"""

# ╔═╡ 21592bdd-d64c-4988-b401-dcfa66bb5077
md"""
## Display Boards with Style Changes
"""

# ╔═╡ de1ea78f-a7e3-47ca-ae8e-c0bb4b0a0824
@bind displayboardstyles PlutoUI.combine() do Child
	md"""
	Select cell color:
	$(Child(ColorStringPicker(default = "#aabbcc")))
	Select cell size in pixels:
	$(Child(Slider(10:200, default = 75, show_value=true)))
	"""
end

# ╔═╡ eccb2779-8ffd-4f8c-828d-f1416e7f9d3f
md"""
## Display Multiple Boards
Using the `displayboards` function, one can display and later style a series a boards in a flexbox HTML container which allows wrapping to multiple rows.  The displayed state of each board is controled by this board selector.
"""

# ╔═╡ 7856fc0d-7fd9-406f-b4d3-cf9c11b07aba
md"""
## Using Combine With Boards
In order to display board controllers effectively with `combine` some html is helpful to render them horizontally.

Notice that this only changes the cosmetic appearance of teh controller, not the state.

Cell Size $(@bind doubleboardsize Slider(30:150, default = 50, show_value=true))

Left Color $(@bind doubleboardcolor1 ColorStringPicker(default = "#72fdff"))
"""

# ╔═╡ c5b444fc-bda7-43e5-96f2-fd4bd0398699
md"""
# Board Creation and Styling
"""

# ╔═╡ 27a315bb-8b3e-4d06-9bcb-d2e27725193a
md"""
## Style and JavaScript
"""

# ╔═╡ 6c591d4c-ee39-11ed-2793-aba6198785ce
const base_cell_style = HTML("""
		<style>
		.grid-container {
			margin: 10px;
			display: grid;
			justify-content: center;
			align-content: center;
			grid-template-columns: repeat(3, auto);
			background-color: rgb(31, 31, 31);
		}

		.grid-container .gridcell.x::before,
		.grid-container .gridcell.x::after,
		.grid-container.x .gridcell:hover:not(.x):not(.o)::before,
		.grid-container.x .gridcell:hover:not(.x):not(.o)::after {
			content: '';
			position: absolute;
			background-color: black;
			width: 10%;
			height: 90%;
		}

		.grid-container .gridcell.x::before,
		.grid-container.x .gridcell:hover::before {
			transform: rotate(45deg);
		}

		.grid-container .gridcell.x::after,
		.grid-container.x .gridcell:hover::after {
			transform: rotate(-45deg);
		}

		.grid-container .gridcell.o::before, 
		.grid-container.o .gridcell:hover:not(.x):not(.o)::before
		{
			content: '';
			background-color: rgba(1, 1, 1, 0);
			border: 10px solid black;
			border-radius:50%;
			width: 65%;
			height: 65%;
		}

		.grid-container.x .gridcell:hover:not(.x):not(.o)::before,
		.grid-container.x .gridcell:hover:not(.x):not(.o)::after {
			background-color: gray;
		}

		.grid-container.o .gridcell:hover:not(.x):not(.o)::before {
			border-color: gray;
		}
		
		.gridcell {
			border: 1px solid black;
			display: flex;
			justify-content: center;
			align-items: center;
			position: relative;
			cursor: pointer;
			width: vw/10;
			height: vw/10;
		}

		.gridcell.x, .gridcell.o {
			cursor: not-allowed;
		}

		.gridcell:first-child,
		.gridcell:nth-child(2),
		.gridcell:nth-child(3) {
			border-top: none;
		}

		.gridcell:nth-child(3),
		.gridcell:nth-child(6),
		.gridcell:nth-child(9) {
			border-right: none;
		}

		.gridcell:nth-child(7),
		.gridcell:nth-child(8),
		.gridcell:nth-child(9) {
			border-bottom: none;
		}

		.gridcell:nth-child(1),
		.gridcell:nth-child(4),
		.gridcell:nth-child(7) {
			border-left: none;
		}
	</style>
""")

# ╔═╡ e31fdf14-77df-40e8-bec6-5c3a361ce5a4
function make_board_script(name) 
	"""
<script>
	const resetButton = document.querySelector(".$name .resetButton");
	console.log("got button")
	console.log(resetButton)
	resetButton.addEventListener("click", resetClick);
	resetButton.onclick = console.log("clicked");
	
	const X_CLASS = 'x'
	const CIRCLE_CLASS = 'o'
	const span = currentScript.parentElement
	const board = document.querySelector('.grid-container.$name')
	const cells = [...board.children];
	
	let circleTurn 

	span.value = [$(zeros(Int64, 9)), '$name']
	span.dispatchEvent(new CustomEvent('input'))

	cells.forEach ((child) => {
		child.addEventListener('click', handleClick, {once: true});    
	})

	function resetClick(e) {
		console.log('button pushed')
		restart()
	}

	function restart() {
		circleTurn = false
		cells.forEach((cell) => {
			var index = cells.indexOf(cell);
			cell.classList.remove(X_CLASS);
			cell.classList.remove(CIRCLE_CLASS);
			cell.removeEventListener('click', handleClick);
			cell.addEventListener('click', handleClick, {once: true});
			span.value[0][index] = 0;
		})
		setBoardHoverClass()
		span.dispatchEvent(new CustomEvent('input'))
	}

	function handleClick(e) {
		const cell = e.target;
		const index = cells.indexOf(cell);
		console.log('cell ', index, ' clicked');
		const currentClass = circleTurn ? CIRCLE_CLASS : X_CLASS;
		const fillValue = circleTurn ? 2 : 1;
		placeMark(cell, currentClass);
		swapTurns();
		setBoardHoverClass();
		span.value[0][index] = fillValue;
		span.dispatchEvent(new CustomEvent('input'));
	}

	function placeMark(cell, currentClass) {
		cell.classList.add(currentClass)
	}

	function setBoardHoverClass() {
		board.classList.remove(X_CLASS)
		board.classList.remove(CIRCLE_CLASS)
		if (circleTurn) {
			board.classList.add(CIRCLE_CLASS)
		} else {
			board.classList.add(X_CLASS)
		}
				
	}

	function swapTurns() {
		circleTurn = !circleTurn
	}
	
</script>
"""
end

# ╔═╡ e1907490-9fa7-4d79-9f89-bbce5bc9848c
md"""
## Board Display and Control
"""

# ╔═╡ aaaf6e33-2087-4891-b1f4-743ff5e72a54
md"""
## Utilities for Styling
"""

# ╔═╡ 1c274453-55e3-4f22-871a-9c04390974af
const no_color = "rgba(0, 0, 0, 0)"

# ╔═╡ d23b4967-e97c-4252-82cf-04adfabd3f24
joinelements(a, b) =  """$a \n $b"""

# ╔═╡ c2ad8675-b692-4870-9778-f259d333e402
make_elems(f, iter) = mapreduce(f, joinelements, iter)

# ╔═╡ 075bcef3-5a71-445f-ac15-16a0e566cdef
function colorcell(name, i, c)
	"""
	.grid-container.$name .gridcell:nth-child($i) {
		background-color: $c;
	}
	"""
end

# ╔═╡ 58c5d965-2216-4b30-83ac-40693c2f12a1
function colorboard(name::AbstractString, colors::AbstractVector{T}) where T <: AbstractString
	HTML("""
	<style>
	$(make_elems(i -> colorcell(name, i, colors[i]), 1:9))
	</style>
	""")
end

# ╔═╡ 0ed2f885-84dc-4257-b4e9-babfe31d1b9d
#display boards in rows that wrap to the next line
function displayboards(boards)
	HTML("""
	<span class=multiboard>
	$(reduce(joinelements, boards))
	</span>
	<style>
		.multiboard {
			display: flex;
			flex-wrap: wrap;
		}
	</style>
""")
end

# ╔═╡ a3cb56da-f373-400e-9b4c-6585509814c9
function resize_board(name, cellsize)
	HTML("""
	<style>
	.grid-container.$name .gridcell {
			width: $(cellsize)px;
			height: $(cellsize)px;
		}
	.grid-container.$name .gridcell.o::before, 
	.grid-container.$name.o .gridcell:hover:not(.x):not(.o)::before
	{
		border: $(cellsize/10)px solid black;
	}
	.grid-container.$name.o .gridcell:hover:not(.x):not(.o)::before {
			border-color: gray;
		}
	.$name .resetButton {
		font-size: $(min(20, cellsize/3))px;
	}
	</style>
""")
end

# ╔═╡ 2f928640-dbcb-4168-a192-68b3f290af6e
prb_to_color(p::AbstractFloat) = "rgb(40, $(max(40, .9*round(Int64, 255*(p .^(1/2))))), 40)"

# ╔═╡ 0530a9ec-0b27-4684-88c1-7d17c7ab5e65
makecolors(prbs::AbstractVector{T}) where T <: AbstractFloat = prb_to_color.(prbs)

# ╔═╡ 891cf135-dcf9-4368-8a45-4219b9f7d02d
resize_boards(boardnames::Union{AbstractVector{T}, Base.Generator}, size) where T <: AbstractString = HTML(reduce(joinelements, (resize_board(b, size).content for b in boardnames)))

# ╔═╡ a9caeaba-40e0-47ff-a3e7-0e2f56410d36
randomclassname(n = 20) = string(rand('a':'z'), String(rand(['a':'z'; '0':'9'; '_'; '-'], 20)))

# ╔═╡ 8b013122-4a3e-49f9-aa5e-0bfd0c01c47c
is_o_move(board) = Bool(sum(board) % 0x0003)

# ╔═╡ d3a23815-e4ea-45f8-8d2a-ac0fceca49f7
#option to just make every cell the same color
colorboard(name, color::AbstractString) = colorboard(name, fill(color, 9))

# ╔═╡ 78ec9799-ecea-45e0-8196-df46f12274f4
function make_ttt_board_raw(board; colors = ["rgba(0, 0, 0, 0)" for _ in 1:9], cellsize = 100, name = randomclassname())
	function makehtmlcell(v)
		str = if v == 1
			" x"
		elseif v == 2
			" o"
		else
			""
		end
		"""<div class = "gridcell$str"></div>"""
	end
	gridstr(board) = is_o_move(board) ? "o" : "x"
	function makecontainer(board, name)
		"""
		<div class = "grid-container $name $(gridstr(board))">
			$(makecells(board))
		</div>
		"""
	end
	
	makecells(board) = make_elems(makehtmlcell, board)

	board = """
	$(makecontainer(board, name))
	$(colorboard(name, colors).content)
	$(resize_board(name, cellsize).content)
	"""
	(board = board, id = name)
end

# ╔═╡ b1657d32-a4fc-483d-8abb-f0eee77cd737
rawdisplayboard = make_ttt_board_raw([[1, 2]; zeros(7)]) 

# ╔═╡ 19cde3ad-df34-4d07-bf19-16d80014f3a7
#visualize game board
HTML(first(rawdisplayboard))

# ╔═╡ 1d995e01-4fdb-42f3-8eed-d4c78302bd28
#calling this with a single color will assume that every cell should be the same color
colorboard(last(rawdisplayboard), displayboardstyles|>first)

# ╔═╡ fbb5c9a3-32ba-4a34-adc3-5e9e6fd5b435
#resize a board with a given id, size is in pixels
resize_board(last(rawdisplayboard), last(displayboardstyles))

# ╔═╡ 9e72a8a3-c5e2-4a04-af8b-d01b0793e810
#create interactive board that works with @bind
function TTTBoard(;cellsize = 100, alignment = "flex-start")
	(board, id) = make_ttt_board_raw(zeros(9); cellsize = cellsize) #make empty board
	js = make_board_script(id)
	HTML(
		"""
		<span class = $id>
			<button class="resetButton">Reset Board</button>
			<div class = "board-value"></div>
			$board
			$js
		</span>
		<style>
			.$id {
				display: flex;
				flex-direction: column;
				align-items: $alignment;
			}
		</style>
		"""
	)
end

# ╔═╡ 959411d9-ba40-4a8f-82ec-44dfcb5f436b
md"""
## Single board without styling
Playable Tic Tac Toe Board.  The moves on the board can be bound to a variable.  The bound variable always is a tuple containing 1) A vector of length 9 representing the board state where 0, 1, and 2 represent blank, X, and O respectively. 2) A name randomly generated to distinguish the board from any future boards that may be created.  This name can also be used to style to board in later cells.  Changes to the board state can be achieved by clicking with the mouse.

$(@bind demoboard TTTBoard())
"""

# ╔═╡ b65609b3-8334-4628-bd21-e3bb8b8d5972
#observe board state changing after clicking
demoboard

# ╔═╡ 6afcc84f-9418-4343-a245-cf3bf00f12cf
md"""
Using the unique identifier for this board and the function `colorboard` we can apply colors to the grid cells that reflect the play state.  Here I've simply colored squares based on the move, but in genral any function of the board state that produces a vector of 9 colors can be used.  Also, numbers from 0 to 1 can be used in place of color strings which will be mapped to colors from gray to green.  Observe the color change while playing moves.

$(@bind styledboard TTTBoard())
"""

# ╔═╡ 1ce54fe0-4b85-405b-bf0a-abd7cb8d343c
colorboard(styledboard[2], [v == 1 ? "green" : v == 2 ? "red" : "blue" for v in styledboard[1]])

# ╔═╡ 1c8c2776-97a4-493f-9b7a-d12d328657f6
@bind multiboardstate TTTBoard(cellsize=70)

# ╔═╡ c3e7bf6f-c713-4cee-a20f-8f8ed5230116
#generate multiple boards with custom coloring
testboards = [make_ttt_board_raw(multiboardstate[1]; cellsize = 30, colors = makecolors(rand(9))) for _ in 1:9]

# ╔═╡ b1587084-03ab-46c9-858b-fc2fc69191dd
#display multiple boards in one cell
displayboards((b.board for b in testboards))

# ╔═╡ dfdb0408-15e6-40d5-a426-dda4a295e5ba
#resize set of boards to 30 pixel cells
resize_boards((t.id for t in testboards), 30)

# ╔═╡ 35993508-6c61-4744-a447-4746e157fd24
#eliminate the colors of the last board
colorboard(last(testboards).id, no_color)

# ╔═╡ 7c3aaa4c-4f10-47de-bbc1-84e876a7e532
@bind doubleboard PlutoUI.combine() do Child
	@htl("""
		<span id=board2control>
		$(Child(TTTBoard()))
		$(Child(TTTBoard()))
		</span>
		<style>
		#board2control {
			display: flex;
			justify-content:center;
			flex-wrap: wrap;
		}
		</style>
	""")
end

# ╔═╡ af296b3f-6881-425d-87bf-1de14c8f299e
#both board states visible in output
doubleboard

# ╔═╡ 29ea9f9c-e0e5-4b75-bc5f-e953b8bc2c2f
#color the first board teal
colorboard(doubleboard |> first |> last, doubleboardcolor1)

# ╔═╡ 31f73016-8565-413c-bddf-01de41a52d2e
#resize both boards to 50 pixel cells
resize_boards([last(b) for b in doubleboard], doubleboardsize)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.51"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0-rc3"
manifest_format = "2.0"
project_hash = "a449faa4600896df45ab8629593ebba092bed48d"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.7.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─78f67226-07de-40a7-85ac-125eb3d207d7
# ╠═cde42e11-533c-46c3-93b2-0faa1fe98d2d
# ╟─9ce498a3-2e64-4e45-bea0-da73b15fa714
# ╟─959411d9-ba40-4a8f-82ec-44dfcb5f436b
# ╠═b65609b3-8334-4628-bd21-e3bb8b8d5972
# ╟─470620fe-e698-41a6-9d86-e8c3cd4abb02
# ╟─6afcc84f-9418-4343-a245-cf3bf00f12cf
# ╠═1ce54fe0-4b85-405b-bf0a-abd7cb8d343c
# ╟─5cb21f86-fc56-42d4-94c9-a4fb8a60eb58
# ╠═b1657d32-a4fc-483d-8abb-f0eee77cd737
# ╟─21592bdd-d64c-4988-b401-dcfa66bb5077
# ╟─de1ea78f-a7e3-47ca-ae8e-c0bb4b0a0824
# ╟─19cde3ad-df34-4d07-bf19-16d80014f3a7
# ╠═1d995e01-4fdb-42f3-8eed-d4c78302bd28
# ╠═fbb5c9a3-32ba-4a34-adc3-5e9e6fd5b435
# ╟─eccb2779-8ffd-4f8c-828d-f1416e7f9d3f
# ╠═1c8c2776-97a4-493f-9b7a-d12d328657f6
# ╠═c3e7bf6f-c713-4cee-a20f-8f8ed5230116
# ╠═b1587084-03ab-46c9-858b-fc2fc69191dd
# ╠═dfdb0408-15e6-40d5-a426-dda4a295e5ba
# ╠═35993508-6c61-4744-a447-4746e157fd24
# ╟─7856fc0d-7fd9-406f-b4d3-cf9c11b07aba
# ╟─7c3aaa4c-4f10-47de-bbc1-84e876a7e532
# ╠═af296b3f-6881-425d-87bf-1de14c8f299e
# ╠═29ea9f9c-e0e5-4b75-bc5f-e953b8bc2c2f
# ╠═31f73016-8565-413c-bddf-01de41a52d2e
# ╟─c5b444fc-bda7-43e5-96f2-fd4bd0398699
# ╟─27a315bb-8b3e-4d06-9bcb-d2e27725193a
# ╠═6c591d4c-ee39-11ed-2793-aba6198785ce
# ╠═e31fdf14-77df-40e8-bec6-5c3a361ce5a4
# ╟─e1907490-9fa7-4d79-9f89-bbce5bc9848c
# ╠═78ec9799-ecea-45e0-8196-df46f12274f4
# ╠═9e72a8a3-c5e2-4a04-af8b-d01b0793e810
# ╟─aaaf6e33-2087-4891-b1f4-743ff5e72a54
# ╠═1c274453-55e3-4f22-871a-9c04390974af
# ╠═d23b4967-e97c-4252-82cf-04adfabd3f24
# ╠═c2ad8675-b692-4870-9778-f259d333e402
# ╠═075bcef3-5a71-445f-ac15-16a0e566cdef
# ╠═58c5d965-2216-4b30-83ac-40693c2f12a1
# ╠═0ed2f885-84dc-4257-b4e9-babfe31d1b9d
# ╠═a3cb56da-f373-400e-9b4c-6585509814c9
# ╠═2f928640-dbcb-4168-a192-68b3f290af6e
# ╠═0530a9ec-0b27-4684-88c1-7d17c7ab5e65
# ╠═891cf135-dcf9-4368-8a45-4219b9f7d02d
# ╠═a9caeaba-40e0-47ff-a3e7-0e2f56410d36
# ╠═8b013122-4a3e-49f9-aa5e-0bfd0c01c47c
# ╠═d3a23815-e4ea-45f8-8d2a-ac0fceca49f7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
