terraform {
	backend "remote" {
		organization = "oracledemo" # org name from step 2.
		workspaces {
			name = "oci-github-vcn" # name for your app's state.
		}
	}
}