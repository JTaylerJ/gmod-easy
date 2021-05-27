easy()

function meta_color:Alpha(value)
	self.a = value
end

function meta_color:Copy()
	return Color(self.r, self.g, self.b)
end
