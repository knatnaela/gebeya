'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Plus, Edit, Trash2, Star, MapPin } from 'lucide-react';
import { toast } from 'sonner';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';

const locationSchema = z.object({
  name: z.string().min(1, 'Location name is required'),
  address: z.string().optional(),
  phone: z.string().optional(),
});

type LocationFormData = z.infer<typeof locationSchema>;

export default function LocationsPage() {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingLocation, setEditingLocation] = useState<any>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [locationToDelete, setLocationToDelete] = useState<any>(null);
  const queryClient = useQueryClient();

  const { data: locations, isLoading } = useQuery({
    queryKey: ['locations'],
    queryFn: async () => {
      const res = await apiClient.get('/locations');
      return res.data.data || [];
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: LocationFormData) => {
      const res = await apiClient.post('/locations', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['locations'] });
      toast.success('Location created successfully');
      setIsDialogOpen(false);
      reset();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to create location');
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<LocationFormData> & { isActive?: boolean } }) => {
      const res = await apiClient.put(`/locations/${id}`, data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['locations'] });
      toast.success('Location updated successfully');
      setIsDialogOpen(false);
      setEditingLocation(null);
      reset();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update location');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const res = await apiClient.delete(`/locations/${id}`);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['locations'] });
      toast.success('Location deleted successfully');
      setDeleteDialogOpen(false);
      setLocationToDelete(null);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to delete location');
    },
  });

  const setDefaultMutation = useMutation({
    mutationFn: async (id: string) => {
      const res = await apiClient.patch(`/locations/${id}/set-default`);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['locations'] });
      toast.success('Default location updated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to set default location');
    },
  });

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<LocationFormData>({
    resolver: zodResolver(locationSchema),
  });

  const onSubmit = (data: LocationFormData) => {
    if (editingLocation) {
      updateMutation.mutate({ id: editingLocation.id, data });
    } else {
      createMutation.mutate(data);
    }
  };

  const handleEdit = (location: any) => {
    setEditingLocation(location);
    reset({
      name: location.name,
      address: location.address || '',
      phone: location.phone || '',
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (location: any) => {
    setLocationToDelete(location);
    setDeleteDialogOpen(true);
  };

  const handleSetDefault = (locationId: string) => {
    setDefaultMutation.mutate(locationId);
  };

  const handleDialogOpenChange = (open: boolean) => {
    setIsDialogOpen(open);
    if (!open) {
      setEditingLocation(null);
      reset();
    }
  };

  const handleNewLocation = () => {
    setEditingLocation(null);
    reset();
    setIsDialogOpen(true);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-muted-foreground">Loading locations...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Locations</h1>
          <p className="text-muted-foreground">Manage your warehouses and stores</p>
        </div>
        <Button onClick={handleNewLocation}>
          <Plus className="h-4 w-4 mr-2" />
          Add Location
        </Button>
        <Dialog open={isDialogOpen} onOpenChange={handleDialogOpenChange}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>{editingLocation ? 'Edit Location' : 'Add New Location'}</DialogTitle>
              <DialogDescription>
                {editingLocation ? 'Update location details' : 'Create a new warehouse or store location'}
              </DialogDescription>
            </DialogHeader>
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div>
                <Label htmlFor="name">Location Name *</Label>
                <Input
                  id="name"
                  {...register('name')}
                  placeholder="e.g., Main Warehouse, Store 1"
                  className="mt-1"
                />
                {errors.name && (
                  <p className="text-sm text-red-500 mt-1">{errors.name.message}</p>
                )}
              </div>
              <div>
                <Label htmlFor="address">Address</Label>
                <Input
                  id="address"
                  {...register('address')}
                  placeholder="Enter location address"
                  className="mt-1"
                />
              </div>
              <div>
                <Label htmlFor="phone">Phone</Label>
                <Input
                  id="phone"
                  {...register('phone')}
                  placeholder="Enter phone number"
                  className="mt-1"
                />
              </div>
              <div className="flex justify-end gap-2 pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => handleDialogOpenChange(false)}
                  disabled={createMutation.isPending || updateMutation.isPending}
                >
                  Cancel
                </Button>
                <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>
                  {editingLocation ? 'Update' : 'Create'}
                </Button>
              </div>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>All Locations</CardTitle>
          <CardDescription>
            {locations?.length || 0} location{locations?.length !== 1 ? 's' : ''} configured
          </CardDescription>
        </CardHeader>
        <CardContent>
          {!locations || locations.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <MapPin className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>No locations found</p>
              <p className="text-sm mt-2">Create your first location to get started</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Address</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {locations.map((location: any) => (
                  <TableRow key={location.id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {location.isDefault && (
                          <Badge variant="default" className="flex items-center gap-1">
                            <Star className="h-3 w-3" />
                            Default
                          </Badge>
                        )}
                        <span className="font-medium">{location.name}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      {location.address || <span className="text-muted-foreground">-</span>}
                    </TableCell>
                    <TableCell>
                      {location.phone || <span className="text-muted-foreground">-</span>}
                    </TableCell>
                    <TableCell>
                      {location.isActive ? (
                        <Badge variant="default">Active</Badge>
                      ) : (
                        <Badge variant="secondary">Inactive</Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {!location.isDefault && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleSetDefault(location.id)}
                            disabled={setDefaultMutation.isPending}
                            title="Set as default"
                          >
                            <Star className="h-4 w-4" />
                          </Button>
                        )}
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleEdit(location)}
                          title="Edit location"
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        {!location.isDefault && (
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(location)}
                            title="Delete location"
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Location</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete &quot;{locationToDelete?.name}&quot;? This action cannot be undone.
              {locationToDelete?.isDefault && (
                <span className="block mt-2 text-amber-600">
                  This is the default location. Another location will be set as default.
                </span>
              )}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setLocationToDelete(null)}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => locationToDelete && deleteMutation.mutate(locationToDelete.id)}
              className="bg-red-600 hover:bg-red-700"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

