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

# ╔═╡ 2309377d-fa85-4ba5-b1be-9c49d1ae9886
begin
	using PlutoUI, Random, HypertextLiteral, StaticArrays
	TableOfContents()
end

# ╔═╡ c6f8ad99-9200-4ff2-b0d5-e6ac7cb893c2
using Transducers

# ╔═╡ 503b348a-f3af-11ed-043e-a93ac4f37a8e
md"""
# Package Dependencies
"""

# ╔═╡ 2cc98f92-65d1-44e9-85e0-a349e410c26f
md"""
# Wordle Feedback Display
"""

# ╔═╡ 34c88911-bed5-4e78-a838-c6fa8af00694
md"""
## Pattern Display Function
Shows an animation of the feedback being revealed for a given guess and answer.  Requires each word be 5 characters.
"""

# ╔═╡ 83e390c1-16e8-4ba5-abf8-c8fadddf7868
md"""
The basis for these colors is the `get_feedback` function that calculates the appropriate values for each character and represents them as 0, 1, or 2
"""

# ╔═╡ a8d4d605-b8eb-4c98-8876-265ebb302f7f
md"""
## Reactive Guess Submission and Display
Demonstrates two input fields that only accept 5 character words which are sent to the `show_pattern` function to visualize the feedback.  You can see the letters populate as you type the guess and then get converted to feedback after the guess is submitted.
"""

# ╔═╡ ab8f97de-074d-4209-9920-74cef8a46837
md"""### Answer"""

# ╔═╡ 02d7d45a-cd01-4ec0-b3d5-976d4dca5302
md"""### Guess"""

# ╔═╡ 3eaa13a2-9979-43c4-87d2-f28dd4ad48d4
md"""
## View Feedback Combinations
Each integer from 0 to 242 is associated with a given set of feedback using ternary encoding.  Using these integers we can view all the possible color patterns.
"""

# ╔═╡ bdf2524f-04a1-4ad4-9ba0-367e72e81994
md"""
# Functions
## Wordle Feedback Calculation
"""

# ╔═╡ bb7ee773-cd7e-4427-8cab-567410716dfb
const EXACT = 0x02

# ╔═╡ a5ac89f2-0dde-42a3-96bb-9629c7b2a24e
const MISPLACED = 0x01

# ╔═╡ 4b2ceb3c-3fcd-4912-935c-c54516d322e8
const MISSING = 0x00

# ╔═╡ c8e8c213-94c0-4295-9ee5-e5c3eef67097
const letters = collect('a':'z')

# ╔═╡ 4a009918-f860-4b74-a7a1-2c371600868e
const letterlookup = Dict(zip(letters, UInt8.(1:length(letters))))

# ╔═╡ 9a8e0ad9-b402-4b94-8a74-629861bc5999
function get_feedback(guess::SVector{5, Char}, answer::SVector{5, Char})
	output = zeros(UInt8, 5)
	counts = zeros(UInt8, 26)

	#green pass
	for (i, c) in enumerate(answer)
		j = letterlookup[c]
		#add to letter count in answer
		counts[j] += 0x01
		#exact match
		if c == guess[i]
			output[i] = EXACT
			#exclude one count from yellow pass
			counts[j] -= 0x01
		end
	end

	#yellow pass
	for (i, c) in enumerate(guess)
		j = letterlookup[c]
		if (output[i] == 0) && (counts[j] > 0)
			output[i] = MISPLACED
			counts[j] -= 0x01
		end
	end
	return SVector{5}(output)
end

# ╔═╡ dd76a2a5-f32c-4c10-b6a1-d690a31ae813
get_feedback(guess::AbstractString, answer::AbstractString) = get_feedback(SVector{5, Char}(collect(lowercase(guess))), SVector{5, Char}(collect(lowercase(answer))))

# ╔═╡ 7a6f6ee7-5992-43e2-8c23-35e94e7e4d91
feedback = get_feedback("whose", "happy")

# ╔═╡ 72d7a142-ac07-4dea-934e-7ad3e36f127b
md"""
## Wordle Feedback Visualization
"""

# ╔═╡ 9f778262-c791-4957-a750-28c0392f39a9
const colorlookup = Dict([0x00 => "#3a3a3c", 0x01 => "#b59f3b", 0x02 => "#538d4e"])

# ╔═╡ 37d4ce45-c3a0-4202-befd-099efc0a8493
const final_box_style = """color: #ffffff;"""

# ╔═╡ 042d38e6-edfc-4b08-81c5-497ce5c1eaee
function add_elements(a::AbstractString, b::AbstractString)
	"""
	$a
	$b
	"""
end

# ╔═╡ 4ce43a3b-afad-4f10-9ce4-0bc48d3de0c2
add_elements(a::HTML, b::HTML) = add_elements(a.content, b.content)

# ╔═╡ 0dc1b5d6-f62e-44f6-875f-38873f337efc
add_elements(a::HTML, b::AbstractString) = add_elements(a.content, b)

# ╔═╡ 332e3018-5134-4c6f-b7f8-3770a8ca2ba5
add_elements(a::AbstractString, b::HTML) = add_elements(a, b.content)

# ╔═╡ cf667532-40de-4a1e-9e26-9f458e7ded70
const basewordlestyle = HTML(
	"""
	<style>
		:root {
			--container-width: min(600px, 90vw);
		}
		.wordle-box {
			display: flex;
			width: var(--container-width);
			height: calc(1.4*var(--container-width)/5);
			justify-content: space-around;
			align-items: center;
			margin: calc(var(--container-width)/150);
		}
		.wordle-box * {
			display: inline-flex;
			width: calc(var(--container-width)/5/1.1);
			height: calc(var(--container-width)/5/1.1);
			aspect-ratio: 1;
			align-items: center;
			justify-content: center;
			vertical-align: middle;	
			font-family: "nyt-franklin", sans-serif;
			font-weight: bold;
			display: inline-flex;
			box-sizing: border: box;
			text-align: center;
			-webkit-font-smoothing: antialiased;
			text-transform: uppercase;
			font-size: calc(var(--container-width)/5/2.0); 
		}

		.inputbox {
			background-color: rgba(0, 0, 0, 0);
			color: rgba(0, 0, 0, 0); 
		}
	</style>
	"""
)

# ╔═╡ d07ecb11-b9b9-44ac-8b71-2efd18f19cde
function wordle_restyle(f::Real, class::String) 
	"""
	<style>
		.wordle-box.$class {
			width: calc($f*var(--container-width));
			height: calc($f*1.2*var(--container-width)/5);
		}
		.wordle-box.$class * {
			display: inline-flex;
			width: calc($f*var(--container-width)/5/1.3);
			height: calc($f*var(--container-width)/5/1.3);
			margin: calc($f*var(--container-width)*0.04/5/1.3);
			font-size: calc($f*var(--container-width)/5/2.0); 
		}
	</style>
	"""
end

# ╔═╡ 594fb234-22c4-4dc2-818d-ec4b0525b3cd
function show_pattern(guess, answer; sizepct = 1.0, repeat = 1)
	feedback = get_feedback(guess, answer)
	colors = [colorlookup[i] for i in feedback]

	function make_base_animation(i)
		"""
		
		@keyframes $guess$answer$i {
			0% {transform: rotateX(90deg); background-color: rgba(0, 0, 0, 0); color: rgba(0, 0, 0, 0);}	
			50% {transform: rotateX(0deg); background-color: $(colors[i]); $final_box_style}
			100% {transform: rotateX(0deg); background-color: $(colors[i]); $final_box_style}
		}
		"""
	end

	function make_win_style(i)
		"""
		@keyframes $guess$answer$(i)2 {
			0% {transform: translateY(0px);}
			50% {transform: translateY(-.33em);}
			75% {transform: translateY(0.2em);}
			100% {transform: translateY(0px);}
		}
		.wordle-box.$guess$answer #box$i {
			animation: $guess$answer$i 2s $(2*i/5)s both, $guess$answer$(i)2 0.7s $(2.1 + i/8)s ease-in-out $repeat;
		}	
		"""
	end

	function make_box_style(i)
		"""
		.wordle-box.$guess$answer #box$i {
			animation: $guess$answer$i 2s $(2*i/5)s both $repeat;
		}	
		"""
	end

	box_style = guess == answer ? make_win_style : make_box_style

	function make_box(i)
		"""
		<div class = inputbox id = "box$i">$(guess[i])</div>
		"""
	end
	restyle = if sizepct == 1
		""""""
	else
		wordle_restyle(sizepct, cname)
	end

	HTML("""
	<span id = wordleoutput>
		<div class="wordle-box $guess$answer">
			$(mapreduce(make_box, add_elements, 1:5))
		</div>
	<style>
		$(mapreduce(make_base_animation, add_elements, 1:5))
		$(mapreduce(box_style, add_elements, 1:5))
	</style>
	$restyle
	</span>
	""")
end

# ╔═╡ c377589a-af21-42e9-9bdc-432442a8ccbc
show_pattern(pnum::Integer; kwargs...) = show_pattern(digits(pnum, base=3, pad=5); kwargs...)

# ╔═╡ c55a66aa-d993-4a77-9cb9-a8c7037de7fb
convert_bytes(v::AbstractVector{T}) where T <: Integer = enumerate(v) |> Map(a -> a[2]*3^(a[1]-1)) |> sum

# ╔═╡ 9e50e664-aabe-4b32-8ec9-f89307c7f95c
const winfeedback = fill(EXACT, 5)

# ╔═╡ 572bab4a-18e6-432b-8cc6-ece539a21142
function show_pattern(feedback::AbstractVector{T}; sizepct = 1.0,  repeat = 1) where T <: Integer
	colors = [colorlookup[i] for i in feedback]
	cname = "a$(convert_bytes(feedback))" #class name can't start with a number

	function make_base_animation(i)
		"""
		
		@keyframes $cname$i {
			0% {transform: rotateX(90deg); background-color: rgba(0, 0, 0, 0); color: rgba(0, 0, 0, 0);}	
			50% {transform: rotateX(0deg); background-color: $(colors[i]); $final_box_style}
			100% {transform: rotateX(0deg); background-color: $(colors[i]); $final_box_style}
		}
		"""
	end

	function make_win_style(i)
		"""
		@keyframes $cname$(i)2 {
			0% {transform: translateY(0px);}
			50% {transform: translateY(-.33em);}
			75% {transform: translateY(0.2em);}
			100% {transform: translateY(0px);}
		}
		.wordle-box.$cname #box$i {
			animation: $cname$i 2s $(2*i/5)s both, $cname$(i)2 0.7s $(2.1 + i/8)s ease-in-out $repeat;
		}	
		"""
	end

	function make_box_style(i)
		"""
		.wordle-box.$cname #box$i {
			animation: $cname$i 2s $(2*i/5)s both $repeat;
		}	
		"""
	end

	box_style = all(feedback .== winfeedback) ? make_win_style : make_box_style

	function make_box(i)
		"""
		<div class = inputbox id = "box$i"></div>
		"""
	end

	restyle = if sizepct == 1
		""""""
	else
		wordle_restyle(sizepct, cname)
	end
	
	HTML("""
	<span id = wordleoutput>
		<div class="wordle-box $cname">
			$(mapreduce(make_box, add_elements, 1:5))
		</div>
	<style>
		$(mapreduce(make_base_animation, add_elements, 1:5))
		$(mapreduce(box_style, add_elements, 1:5))
	</style>
	$restyle
	</span>
	""")
end

# ╔═╡ 28e55a1e-66cd-45c3-a04f-c758fc7d55cc
#option to repeat the animation an arbitrary number of times
show_pattern("while", "while"; repeat = "infinite")

# ╔═╡ da01b6d5-6c7d-49dc-933d-e9bf475d91a2
function show_blank_squares(guess)
	word = guess[1]
	ind = guess[2]
	function getclass(i)
		str2 = if (ind !=-1) && ((i-1) == ind)
			"anim"
		else
			""
		end
		"""class = "inputbox $str2" """
	end
	function make_box(i)
		"""
		<div $(getclass(i))>$(length(word) < i ? "" : word[i])</div>
		"""
	end
	HTML("""
	<span id = wordleoutputblank>
		<div class="wordle-box">
			$(mapreduce(make_box, add_elements, 1:5))
		</div>
	</span>
	""")
end

# ╔═╡ c9b7b336-032e-4597-a529-0df2f841f2cf
const inputstyle = HTML("""
	<style>
	#wordleoutputblank .inputbox {
			background-color: rgba(0, 0, 0, 0);
			$final_box_style;
			border: 1px solid gray;
		}
		
	#wordleoutputblank .inputbox.anim {
			animation: addletter 0.2s ease-in-out;
		}
	@keyframes addletter {
		0% {transform: scale(1.0);}
		50% {transform: scale(1.05);}
		100% {transform: scale(1.0);}
	}
	</style>
""")

# ╔═╡ 02274b6f-5a58-41e6-82e1-820c7f888764
md"""
## Wordle Input Element
"""

# ╔═╡ 24327929-c8f5-45b2-80ad-c873daedf677
import AbstractPlutoDingetjes.Bonds

# ╔═╡ ca1cd33a-3d41-4878-8b95-7b7f44353695
begin
	struct WordleInput{T <: AbstractString}
		word::T
		addindex::Integer
	end

	WordleInput(;default="") = WordleInput(uppercase(default), length(default)-1)
	
	function Bonds.show(io::IO, m::MIME"text/html", input::WordleInput)
		show(io, m, HTML("""
		<span>
		<input class=wordleinput type=text oninput="this.value = this.value.replace(/[^a-zA-Z]/, '')" maxlength=5 $(isempty(input.word) ? "" : "value=$(input.word)") size=5>
		<style>
			.wordleinput {
				text-transform:uppercase;
				font-family: "nyt-franklin", sans-serif;
				font-weight: bold;
				font-size: calc(var(--container-width)/5/2.0); 
			}
		</style>
		<script>
			const span = currentScript.parentElement;
			const inputbox = span.querySelector(".wordleinput");
			span.value = [inputbox.value, inputbox.value.length-1];
			inputbox.addEventListener('keydown', handleWordleInput);
			inputbox.addEventListener('input', handleInput); 
			
			function handleInput(e) {
				span.value[0] = inputbox.value;
				if (inputbox.value.length === 0) {
					span.value[1] = -1;
				}
			}
		
			function handleWordleInput(e) {
				if (e.keyCode === 8) {
					span.value[1] = -1;
				} else if (inputbox.value.length === 5) {
					span.value[1] = -1;
				} else if (e.keyCode >= 65 && e.keyCode <= 90) {
					span.value[1] = inputbox.value.length;
				} else {
					span.value[1] = -1;
				} 
			}
		</script>
		</span>
		"""))
	end

	Base.get(input::WordleInput) = input
	Bonds.initial_value(input::WordleInput) = (word = input.word, addindex = input.addindex)
	Bonds.possible_values(input::WordleInput) = Bonds.InfinitePossibilities()
	Bonds.transform_value(input::WordleInput, val_from_js) = (word=uppercase(val_from_js[1]), addindex=val_from_js[2])
end

# ╔═╡ 00b839be-83b0-435e-a903-9728e7b15c8d
@bind testguess TextField(default="whose")

# ╔═╡ 63bb509d-91e1-418e-9a84-10fe7cadf1d0
testguess

# ╔═╡ c4b86aad-67dd-43f5-8e6d-88cc9fd75e68
show_pattern(testguess, "happy")

# ╔═╡ 2b1e631e-e56a-4514-b217-8c1a1b9d43c8
@bind rawanswer confirm(WordleInput(default="apple"))

# ╔═╡ 58cece7f-7b8f-4e33-b5b7-9205b140fc34
if ismissing(rawanswer.word) || rawanswer.word == ""
	answer = ""
	md"""Submit a 5 letter word for the answer"""
elseif occursin(r"^[A-Za-z]{5}$", rawanswer.word)
	answer = rawanswer.word
	md"""Answer successfully submitted as $answer"""
else
	answer = ""
end

# ╔═╡ c514ce23-2762-4e38-b181-accb7fac848c
@bind guess2 WordleInput()

# ╔═╡ 83967bd4-1e9f-4aa7-ab0b-2aa0fcab3229
begin
	if answer == ""
		submit_guess = 0
		md"""Waiting for answer"""
	elseif length(guess2.word) < 5
		submit_guess = 0
		md"""Waiting for guess"""
	else
		@bind submit_guess CounterButton("Submit Guess")
	end
end

# ╔═╡ 0c684bf3-b587-4c90-be22-097d129e99ac
if submit_guess > 0
	md"""
	#### Showing Feedback
	
	$(show_pattern(guess.word, answer))
	"""
else
	feedback_message = answer == "" ? md"""#### Provide answer and submit guess to see feedback""" : md"""#### Submit guess to see feedback"""
	md"""
	$feedback_message
	
	$(show_blank_squares(guess2))
	"""
end

# ╔═╡ 61aa10a8-ed3f-43e4-8b5d-a124fb006f8d
md"""
Select Feedback Value Range: $(@bind startrange NumberField(0:242, default=0)) $(@bind endrange NumberField(0:242, default = 242))
"""

# ╔═╡ 182437d7-a2e9-442b-b2b2-e506e439119a
HTML("""
<span class=testview>
$(mapreduce(a -> show_pattern(a; sizepct = 0.13), add_elements, startrange:endrange))
</span>

<style>
	.testview {
		display: flex;
		flex-wrap: wrap;
	}
</style>
""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractPlutoDingetjes = "6e696c72-6542-2067-7265-42206c756150"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
Transducers = "28d57a85-8fef-5791-bfe6-a80928e7c999"

[compat]
AbstractPlutoDingetjes = "~1.1.4"
HypertextLiteral = "~0.9.4"
PlutoUI = "~0.7.51"
StaticArrays = "~1.5.25"
Transducers = "~0.4.76"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0"
manifest_format = "2.0"
project_hash = "2e61a7bd61c4b712b5c36219a4b968d609e9ce1d"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "54b00d1b93791f8e19e31584bd30f2cb6004614b"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.38"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

    [deps.CompositionsBase.weakdeps]
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "738fec4d684a9a6ee9598a8bfee305b26831f28c"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.2"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

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

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

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

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7302075e5e06da7d000d9bfa055013e3e85578ca"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.9"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "259e206946c293698122f63e2b513a7c99a244e8"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.1"

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

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "8982b3607a212b070a5e46eea83eb62b4744ae12"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.25"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

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

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "25358a5f2384c490e98abd565ed321ffae2cbb37"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.76"

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
# ╟─503b348a-f3af-11ed-043e-a93ac4f37a8e
# ╠═2309377d-fa85-4ba5-b1be-9c49d1ae9886
# ╟─2cc98f92-65d1-44e9-85e0-a349e410c26f
# ╟─34c88911-bed5-4e78-a838-c6fa8af00694
# ╠═28e55a1e-66cd-45c3-a04f-c758fc7d55cc
# ╟─00b839be-83b0-435e-a903-9728e7b15c8d
# ╠═63bb509d-91e1-418e-9a84-10fe7cadf1d0
# ╠═c4b86aad-67dd-43f5-8e6d-88cc9fd75e68
# ╟─83e390c1-16e8-4ba5-abf8-c8fadddf7868
# ╠═7a6f6ee7-5992-43e2-8c23-35e94e7e4d91
# ╟─a8d4d605-b8eb-4c98-8876-265ebb302f7f
# ╟─ab8f97de-074d-4209-9920-74cef8a46837
# ╟─2b1e631e-e56a-4514-b217-8c1a1b9d43c8
# ╟─58cece7f-7b8f-4e33-b5b7-9205b140fc34
# ╟─02d7d45a-cd01-4ec0-b3d5-976d4dca5302
# ╟─c514ce23-2762-4e38-b181-accb7fac848c
# ╟─83967bd4-1e9f-4aa7-ab0b-2aa0fcab3229
# ╟─0c684bf3-b587-4c90-be22-097d129e99ac
# ╟─3eaa13a2-9979-43c4-87d2-f28dd4ad48d4
# ╟─61aa10a8-ed3f-43e4-8b5d-a124fb006f8d
# ╠═182437d7-a2e9-442b-b2b2-e506e439119a
# ╟─bdf2524f-04a1-4ad4-9ba0-367e72e81994
# ╠═bb7ee773-cd7e-4427-8cab-567410716dfb
# ╠═a5ac89f2-0dde-42a3-96bb-9629c7b2a24e
# ╠═4b2ceb3c-3fcd-4912-935c-c54516d322e8
# ╠═c8e8c213-94c0-4295-9ee5-e5c3eef67097
# ╠═4a009918-f860-4b74-a7a1-2c371600868e
# ╠═9a8e0ad9-b402-4b94-8a74-629861bc5999
# ╠═dd76a2a5-f32c-4c10-b6a1-d690a31ae813
# ╟─72d7a142-ac07-4dea-934e-7ad3e36f127b
# ╠═9f778262-c791-4957-a750-28c0392f39a9
# ╠═37d4ce45-c3a0-4202-befd-099efc0a8493
# ╠═042d38e6-edfc-4b08-81c5-497ce5c1eaee
# ╠═4ce43a3b-afad-4f10-9ce4-0bc48d3de0c2
# ╠═0dc1b5d6-f62e-44f6-875f-38873f337efc
# ╠═332e3018-5134-4c6f-b7f8-3770a8ca2ba5
# ╠═cf667532-40de-4a1e-9e26-9f458e7ded70
# ╠═d07ecb11-b9b9-44ac-8b71-2efd18f19cde
# ╠═594fb234-22c4-4dc2-818d-ec4b0525b3cd
# ╠═c377589a-af21-42e9-9bdc-432442a8ccbc
# ╠═c55a66aa-d993-4a77-9cb9-a8c7037de7fb
# ╠═c6f8ad99-9200-4ff2-b0d5-e6ac7cb893c2
# ╠═9e50e664-aabe-4b32-8ec9-f89307c7f95c
# ╠═572bab4a-18e6-432b-8cc6-ece539a21142
# ╠═da01b6d5-6c7d-49dc-933d-e9bf475d91a2
# ╠═c9b7b336-032e-4597-a529-0df2f841f2cf
# ╟─02274b6f-5a58-41e6-82e1-820c7f888764
# ╠═24327929-c8f5-45b2-80ad-c873daedf677
# ╠═ca1cd33a-3d41-4878-8b95-7b7f44353695
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
